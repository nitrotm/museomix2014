console = require('console')
fs = require('fs')
path = require('path')

rootPath = path.normalize(path.join(__dirname, '..'))
assetsPath = path.join(rootPath, 'assets')
buildPath = path.join(rootPath, 'build')
publicPath = path.join(rootPath, 'public')
viewsPath = path.join(rootPath, 'views')

rmtree = (parent) ->
  return false unless fs.existsSync(parent)
  if fs.statSync(parent).isDirectory()
    fs.readdirSync(parent).forEach( (child) -> rmtree(path.join(parent, child)) )
    fs.rmdirSync(parent)
  else
    fs.unlinkSync(parent)

rmtree(buildPath)
fs.mkdirSync(buildPath)


# configure express
serveStatic = require('serve-static')

app = new require('express')()
app.engine('jade', require('jade').__express)
app.set('views', viewsPath)
app.set('view engine', 'jade')
app.use(
  require('compression')(
  )
)
app.use(
  require('connect-compiler')(
    enabled: ['coffee', 'jade', 'less']
    src: assetsPath
    dest: buildPath
  )
)
app.use(
  serveStatic(publicPath)
)
app.use(
  serveStatic(buildPath)
)


# views
app.get '/generator.html', (req, res) -> res.render('generator')
app.get '/designer.html', (req, res) -> res.render('designer')
app.get '/designer/home.html', (req, res) -> res.render('designer-home')
app.get '/designer/mode.html', (req, res) -> res.render('designer-mode')
app.get '/designer/mode/text.html', (req, res) -> res.render('designer-mode-text')
app.get '/designer/mode/paint.html', (req, res) -> res.render('designer-mode-paint')

#
app.post '/text', (req, res) ->

# datasets
app.get '/dataset', (req, res) ->
  first = true
  rows = []

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
          id: row[1]
          url: 'images/' + row[2] + '-scaled.jpg'
          title: row[3]
          description: row[6]
          room: row[7]
        )
  )
  parser.on(
    'error',
    -> res.end()
  )
  parser.on(
    'finish',
    -> res.end(JSON.stringify(rows))
  )

  res.setHeader('Content-Type', 'application/json')
  res.writeHead(200)

  fs.readFile(
    'data/database.csv',
    (e, data) ->
      return res.end() if e?
      parser.write(data)
      parser.end()
  )


# arduino listener
SerialPort = require('serialport').SerialPort
arduino = new SerialPort(
  'COM4',
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


# printing
child_process = require('child_process')

app.get '/print', (req, res) ->
  res.end('')

  fs.writeFileSync(
    'print.tex',
    """
      % Document type
      \\documentclass[a4paper,10pt]{article}
      \\usepackage[paperwidth=62mm,paperheight=210mm,margin=0mm]{geometry}
      \\usepackage[english]{babel}
      \\usepackage{indentfirst}

      % Standard extensions
      \\usepackage{parskip}
      \\usepackage{float}
      \\usepackage{color}
      \\usepackage{multicol}
      \\usepackage{subcaption}
      \\usepackage[normalem]{ulem}

      % Standard font
      \\usepackage{fontspec}
      \\setmainfont{Arial}

      % Image support
      \\usepackage{graphicx}
      \\usepackage{wallpaper}

      % Tables support
      \\usepackage{tabularx}
      \\usepackage{multirow}


      % Sections configuration
      \\setcounter{secnumdepth}{0}
      \\setcounter{tocdepth}{0}

      % Page formatting
      \\pagestyle{empty}

      \\setlength{\\marginparsep}{0pt}
      \\setlength{\\marginparwidth}{0pt}
      \\setlength{\\parindent}{0pt}
      \\setlength{\\parskip}{1pt}

      % Document content
      \\begin{document}
        \\par\\noindent
        \\parbox[t][20mm][c]{62mm}{
          \\centering
          \\par\\noindent\\textbf{Mixing Art \\& History}
          \\vspace{1mm}
          \\par\\noindent{\\footnotesize 1- Découvrez les œuvres proposées}
          \\par\\noindent{\\footnotesize 2- Rejoignez la table d'expression}
          \\par\\noindent{\\footnotesize 3- Créez et partagez votre histoire}
          \\vspace{1mm}
          \\par\\noindent\\textbf{Votre code: #{req.query.id1}-#{req.query.id2}-#{req.query.id3}}
          \\vspace{1mm}
          \\par\\noindent Bonne visite!}
        \\vspace{3mm}
        \\par\\noindent
        \\parbox[t][50mm][c]{62mm}{
          \\centering
          \\par\\noindent\\includegraphics[height=30mm]{public/images/#{req.query.id1}.jpg}
          \\par\\noindent\\textrm{\\small #{req.query.text1}}
          \\par\\noindent\\textrm{\\footnotesize #{req.query.description1}}
          \\vspace{1mm}
          \\par\\noindent #{req.query.room1}
        }
        \\vspace{3mm}
        \\par\\noindent
        \\parbox[t][50mm][c]{62mm}{
          \\centering
          \\par\\noindent\\includegraphics[height=30mm]{public/images/#{req.query.id2}.jpg}
          \\par\\noindent\\textrm{\\small #{req.query.text2}}
          \\par\\noindent\\textrm{\\footnotesize #{req.query.description2}}
          \\vspace{1mm}
          \\par\\noindent #{req.query.room2}
        }
        \\vspace{3mm}
        \\par\\noindent
        \\parbox[t][50mm][c]{62mm}{
          \\centering
          \\par\\noindent\\includegraphics[height=30mm]{public/images/#{req.query.id3}.jpg}
          \\par\\noindent\\textrm{\\small #{req.query.text3}}
          \\par\\noindent\\textrm{\\footnotesize #{req.query.description2}}
          \\vspace{1mm}
          \\par\\noindent #{req.query.room3}
        }
      \\end{document}
    """
  )

  child = child_process.exec(
    '\\texlive\\2014\\bin\\win32\\xelatex.exe print.tex',
    (err, stdout, stdin) ->
      child_process.exec(
        '\\texlive\\2014\\bin\\win32\\pdf2ps.exe print.pdf',
          (err, stdout, stdin) ->
            child_process.exec(
              '"\\Program Files (x86)\\SumatraPDF\\SumatraPDF.exe" -print-to-default print.pdf'
            )
      )
    )


# bower assets
makeBowerPath = (project, file) -> path.join(rootPath, 'bower_components', project, file)

app.get(
  '/javascripts/jquery.js',
  (req, res) -> res.sendFile(makeBowerPath('jquery', 'dist/jquery.js'))
)
app.get(
  '/javascripts/angular.js',
  (req, res) -> res.sendFile(makeBowerPath('angular', 'angular.js'))
)
app.get(
  '/javascripts/angular-locale-en.js',
  (req, res) -> res.sendFile(makeBowerPath('angular-i18n', 'angular-locale-en.js'))
)
app.get(
  '/javascripts/angular-resource.js',
  (req, res) -> res.sendFile(makeBowerPath('angular-resource', 'angular-resource.js'))
)
app.get(
  '/javascripts/angular-route.js',
  (req, res) -> res.sendFile(makeBowerPath('angular-route', 'angular-route.js'))
)
app.get(
  '/javascripts/angular-resource.js',
(req, res) -> res.sendFile(makeBowerPath('angular-resource', 'angular-resource.js'))
)
app.get(
  '/javascripts/angular-bootstrap.js',
  (req, res) -> res.sendFile(makeBowerPath('angular-bootstrap', 'ui-bootstrap.js'))
)
app.get(
  '/javascripts/angular-bootstrap-tpls.js',
  (req, res) -> res.sendFile(makeBowerPath('angular-bootstrap', 'ui-bootstrap-tpls.js'))
)
app.get(
  '/javascripts/three.js',
  (req, res) -> res.sendFile(makeBowerPath('threejs', 'build/three.js'))
)

# start server
app.listen 8080
