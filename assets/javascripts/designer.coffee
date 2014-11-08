'use strict'

app = angular.module(
  'designerApp',
  [
    'ngResource'
    'ngRoute'
    'database'
    'ui.bootstrap'
    'compositions'
  ]
)


app.config([
  '$locationProvider'
  '$routeProvider'
  ($locationProvider, $routeProvider) ->
    $locationProvider.html5Mode(false)

    $routeProvider.when(
      '/',
      controller: 'HomeController'
      templateUrl: 'designer/home.html'
    )
    $routeProvider.when(
      '/:code/mode.html',
      controller: 'ModeController'
      templateUrl: 'designer/mode.html'
    )
    $routeProvider.when(
      '/:code/text.html',
      controller: 'TextModeController'
      templateUrl: 'designer/mode/text.html'
    )
    $routeProvider.when(
      '/:code/paint.html',
      controller: 'PaintModeController'
      templateUrl: 'designer/mode/paint.html'
    )
])


app.controller(
  'HomeController',
  [
    '$scope'
    '$http'
    'compositions'
    (scope, http, compositions) ->

      scope.sliderInterval = 2000

      scope.compositions = compositions

      scope.processForm = ->
        return unless scope.code?
        window.location = '#/' + scope.code + '/mode.html'
  ]
)

app.controller(
  'ModeController',
  [
    '$scope'
    '$http'
    '$routeParams'
    (scope, http, routeParams) ->
      scope.code = routeParams.code
  ]
)

app.controller(
  'TextModeController',
  [
    '$scope'
    '$http'
    '$routeParams'
    'database'
    'compositions'
    (scope, http, routeParams, database, compositions) ->
      scope.code = routeParams.code
      scope.pictureUrl1 = ''
      scope.pictureUrl2 = ''
      scope.pictureUrl3 = ''

      imagesIds = scope.code.split('-')
      scope.images = []

      database.rows.then(
        (data) ->
          for row in data
            if row.id in imagesIds
              scope.images.push({
                url: row.url
              })
      )

      scope.formData = {}

      scope.processForm = ->
        compositions.push({
          title: scope.formData.title
          images: scope.images
          text: scope.formData.text
        })

        window.location = '#/'
  ]
)

app.controller(
  'PaintModeController',
  [
    '$scope'
    '$http'
    '$routeParams'
    (scope, http, routeParams) ->
      scope.code = routeParams.code
  ]
)
