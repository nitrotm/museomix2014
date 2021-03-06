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
    'database'
    (scope, http, compositions, database) ->

      scope.sliderInterval = 15000
      scope.compositions = []

      http.get('/load').then(
        (data) ->
          nextId = 0
          for row in data.data
            nextId += 1
            scope.compositions.push(
              id: nextId
              title: row.title
              author: row.author
              images: [
                  url: 'images/' + row.id1 + '-scaled.jpg'
                ,
                  url: 'images/' + row.id2 + '-scaled.jpg'
                ,
                  url: 'images/' + row.id3 + '-scaled.jpg'
              ]
              text: row.text
            )
      )

      scope.submit = ->
        imagesIds = scope.code.split('-')

        scope.images = []
        database.rows.then(
          (data) ->
            for row in data
              for imageId in imagesIds
                if (row.id == imageId)
                  scope.images.push({
                    url: row.url
                  })

            if (scope.images.length < 3)
              scope.message = 'Veuillez entrer un code valide.'

              setTimeout(
                ->
                  delete scope.message
                  scope.$digest()
              , 5000
              )

              return false

            return unless scope.code?
            window.location = '#/' + scope.code + '/mode.html'
        )
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

      scope.back = ->
        window.history.back();
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

      scope.back = ->
        window.history.back();

      scope.processForm = ->
        composition =
          id: Date.now()
          title: scope.formData.title
          author: scope.formData.author
          images: scope.images
          text: scope.formData.text

        http.get(
          '/save',
          params:
            id1: imagesIds[0]
            id2: imagesIds[1]
            id3: imagesIds[2]
            title: composition.title
            author: composition.author
            text: composition.text
        )

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
