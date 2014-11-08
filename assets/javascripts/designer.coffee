'use strict'

app = angular.module(
  'designerApp',
  [
    'ngResource'
    'ngRoute'
    'database'
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

      scope.compositions = [
        {
          title: 'I love bacon!',
          images: [
            {
              url: 'http://baconmockup.com/300/200'
            },
            {
              url: 'http://baconmockup.com/300/200'
            },
            {
              url: 'http://baconmockup.com/300/200'
            }
          ],
          text: 'Bla bla bla'
        },
        {
          title: 'I love kitten!',
          images: [
            {
              url: 'http://placekitten.com/g/300/200'
            },
            {
              url: 'http://placekitten.com/g/300/200'
            },
            {
              url: 'http://placekitten.com/g/300/200'
            }
          ],
          text: 'Bla bla bla'
        }
      ]

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
    (scope, http, routeParams, database) ->
      scope.code = routeParams.code
      scope.pictureUrl1 = ''
      scope.pictureUrl2 = ''
      scope.pictureUrl3 = ''

      pictureIds = scope.code.split('-')
      scope.pictureUrls = []

      database.rows.then(
        (data) ->
          for row in data
            if row.id in pictureIds
              scope.pictureUrls.push(row.url)
      )

      scope.formData = {}

      scope.processForm = ->
        http.post(
          'text',
          scope.formData
        ).success( (data) ->
          console.log(data)
        ).error( (data) ->
          console.log('fail')
        )
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
