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


# bower assets
makeBowerPath = (project, file) -> path.join(rootPath, 'bower_components', project, file)

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
  '/javascripts/angular-bootstrap.js',
  (req, res) -> res.sendFile(makeBowerPath('angular-bootstrap', 'ui-bootstrap.js'))
)


# start server
app.listen 8080
