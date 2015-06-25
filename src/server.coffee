console = require('console')
fs = require('fs')
path = require('path')
SerialPort = require('serialport').SerialPort
Iconv = require('iconv').Iconv


rootPath = path.normalize(path.join(__dirname, '..'))
bowerPath = path.join(rootPath, 'bower_components')
buildPath = path.join(rootPath, 'build')
assetsPath = path.join(rootPath, 'assets')
publicPath = path.join(rootPath, 'public')
viewsPath = path.join(rootPath, 'views')

fs.mkdirSync(buildPath) unless fs.existsSync(buildPath)


# configure express
express = require('express')

app = express()
app.set('views', viewsPath)
app.set('view engine', 'jade')
app.use(
  require('compression')(
  )
)
app.use(
  require('connect-coffee-script')(
    src: assetsPath
    dest: buildPath
  )
)
app.use(
  require('less-middleware')(
    assetsPath,
    dest: buildPath
  )
)
app.use(
  express.static(buildPath)
)
app.use(
  express.static(publicPath)
)
app.use(
  express.static(bowerPath)
)


# views
app.get '/', (req, res) -> res.render('generator')

#
app.post '/text', (req, res) ->

# dataset
rows = []
fs.readFile(
  'data/database.csv',
  (e, data) ->
    return res.end() if e?

    first = true
    parser = require('csv-parse')(
      delimiter: ','
    )
    parser.on(
      'readable',
      ->
        while row = parser.read()
          if first
            first = false
            continue
          rows.push(
            id: row[0],
            author: row[1],
            title: row[2]
          )
    )
    parser.on(
      'error',
      -> res.end()
    )

    parser.write(data)
    parser.end()
)

app.get '/dataset', (req, res) ->
  res.setHeader('Content-Type', 'application/json')
  res.writeHead(200)
  res.end(JSON.stringify(rows))


# printing
printer = new SerialPort(
  '/dev/ttyUSB0',
  baudrate: 19200
  dataBits: 8
  stopBits: 1
  parity: false
  rtscts: false
  xon: false
  xoff: false
  flowControl: false
  encoding: 'binary'
)
printer.on(
  'error',
  (e) -> console.log(e)
)
printer.on(
  'data',
  (data) ->
    console.log(data.toString())
)
printer.open(
  ->
    return
)

app.get '/print', (req, res) ->
  res.end('')

  choice1 = rows[parseInt(req.query.id1)]
  choice2 = rows[parseInt(req.query.id2)]
  choice3 = rows[parseInt(req.query.id3)]

  console.log(choice1)
  console.log(choice2)
  console.log(choice3)

  ESC = '\x1b'
  DC2 = '\x12'

  TEXTLEFT = ESC + 'a0'
  TEXTCENTER = ESC + 'a1'
  TEXTRIGHT = ESC + 'a2'

  iconv = new Iconv('UTF-8', 'CP437')

  cmds = [
    # ESC + '@'
    # ESC + 'R' + '\x01',
    TEXTLEFT,
    iconv.convert('+------------------------------+\n'),
    iconv.convert('|           MIX&MAKE           |\n'),
    iconv.convert('+------------------------------+\n'),
    '\n'
  ]

  printImage = (file) ->
    data = new Buffer(fs.readFileSync(file, encoding: 'binary'), 'binary')
    offset = 0
    for y in [0...288]
      row = new Buffer(52)
      row.writeUInt8(0x12, 0)
      row.writeUInt8(0x2a, 1)
      row.writeUInt8(1, 2)
      row.writeUInt8(48, 3)
      group = 0
      count = 0
      for x in [0...384]
        i = x % 8
        if i == 0
          if x > 0
            row.writeUInt8(group, count + 4)
            count += 1
          group = 0
        group |= (1 << (7 - i)) if data.readUInt8(offset) == 0
        offset += 3
      row.writeUInt8(group, count + 4)
      cmds.push(row)

  cmds.push('--------------------------------\n')
  cmds.push(TEXTCENTER)
  cmds.push(iconv.convert(choice1.title))
  cmds.push('\n')
  cmds.push('--------------------------------\n')
  cmds.push(ESC + 'J\x05')
  printImage('data/items/print/' + choice1.id + '.rgb')
  cmds.push(TEXTCENTER)
  cmds.push(iconv.convert(choice1.author))
  cmds.push('\n\n')

  cmds.push('--------------------------------\n')
  cmds.push(TEXTCENTER)
  cmds.push(iconv.convert(choice2.title))
  cmds.push('\n')
  cmds.push('--------------------------------\n')
  cmds.push(ESC + 'J\x05')
  printImage('data/items/print/' + choice2.id + '.rgb')
  cmds.push(TEXTCENTER)
  cmds.push(iconv.convert(choice2.author))
  cmds.push('\n\n')

  cmds.push('--------------------------------\n')
  cmds.push(TEXTCENTER)
  cmds.push(iconv.convert(choice3.title))
  cmds.push('\n')
  cmds.push('--------------------------------\n')
  cmds.push(ESC + 'J\x05')
  printImage('data/items/print/' + choice3.id + '.rgb')
  cmds.push(TEXTCENTER)
  cmds.push(iconv.convert(choice3.author))
  cmds.push('\n\n')

  cmds.push(TEXTLEFT)
  cmds.push(iconv.convert('--------------------------------\n\n'))

  cmds.push(iconv.convert('Tu peux maintenant aller à la\nrecherche de ces 3 éléments.\n\n'))
  cmds.push(iconv.convert('Que pourrais-tu inventer avec\nceux-ci ?\n\n'))
  cmds.push(iconv.convert('Reviens ensuite exprimer tes\nidées les plus créatives!\n\n'))

  cmds.push(iconv.convert('+------------------------------+\n'))
  cmds.push(iconv.convert('|       www.museomix.ch        |\n'))
  cmds.push(iconv.convert('+------------------------------+\n'))
  cmds.push('\n\n\n\n')

  sendNextCmd = ->
    return unless cmds.length > 0
    cmd = cmds[0]
    cmds.splice(0, 1)
    printer.write(cmd, -> setTimeout(sendNextCmd, 50) )

  sendNextCmd()


# arduino listener
arduino = new SerialPort(
  '/dev/ttyUSB1',
  baudrate: 115200
  dataBits: 8
  stopBits: 1
  parity: false
  rtscts: false
  xon: false
  xoff: false
  flowControl: false
)
arduinoBuffer = ''
arduinoTrigger = null
arduinoTriggerTimer = null
arduinoSwitch = 0
arduino.on(
  'error',
  (e) -> console.log(e)
)
arduino.on(
  'data',
  (data) ->
    arduinoBuffer += data.toString()
    i = arduinoBuffer.indexOf('\n')
    if i > 0
      line = arduinoBuffer.substring(0, i + 1).trim()
      arduinoBuffer = arduinoBuffer.substring(i + 1)
      console.log(line)
      if arduinoTrigger
        clearTimeout(arduinoTriggerTimer)
        arduinoTriggerTimer = null
        arduinoTrigger.end('1')
        arduinoTrigger = null
      else
        arduinoSwitch = Date.now()
)

app.get '/trigger', (req, res) ->
  arduinoTrigger = res
  if arduinoSwitch? && (Date.now() - arduinoSwitch) < 60
    arduinoSwitch = 0
    res.end('1')
  else
    arduinoTriggerTimer = setTimeout(
      -> res.end('0')
      ,
      5000
    )


# start server
app.listen 8080
