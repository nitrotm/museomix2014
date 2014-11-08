'use strict'

app = angular.module(
  'designerApp',
  [
    'ngResource'
    'ngRoute'
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
    (scope, http) ->
      # Send code to server
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
    (scope, http, routeParams) ->
      scope.code = routeParams.code
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
