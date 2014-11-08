'use strict'

app = angular.module(
  'app',
  [
    'ngResource'
    'database'
  ]
)

app.controller(
  'GeneratorController',
  [
    '$scope'
    'database'
    '$http'
    (scope, database, $http) ->
      scope.generate = ->
        available = (i for i in [0...scope.choices.length])
        selection = []
        while available.length > 0
          choice = available.splice(
            parseInt(Math.random() * available.length),
            1
          )
          selection.push(scope.choices[choice[0]])
        scope.image1 = selection[0].index
        scope.image2 = selection[1].index
        scope.image3 = selection[2].index
        scope.code = "#{selection[0].id}-#{selection[1].id}-#{selection[2].id}"

      listenTrigger = ->
        $http.get(
          '/trigger',
          timeout: 0
        ).then(
          (data) ->
            scope.generate() if parseInt(data.data) == 1
            listenTrigger()
          ,
          (e) -> listenTrigger()
        )
      listenTrigger()

      database.rows.then(
        (data) ->
          scope.choices = data
          scope.image1 = 0
          scope.image2 = 0
          scope.image3 = 0
      )
  ]
)

app.directive(
  'slotDriver',
  [
    ->
      scope:
        slotSelection: '='
      link: (scope, el) ->
        height = el.height()
        scope.$watch('slotSelection', (value) ->
          return unless value?
          height = 0
          children = el.find('li')
          for i in [0...value]
            height += $(children[i]).outerHeight(true)
          el[0].scrollTop = height
        )
  ]
)
