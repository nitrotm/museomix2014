'use strict'

app = angular.module(
  'app',
  [
  ]
)

app.controller(
  'GeneratorController',
  [
    '$scope'
    (scope) ->
      scope.image1 = 0
      scope.image2 = 0
      scope.image3 = 0

      scope.choices = [
        {
          index: 0
          id: 'HA'
          url: 'images/1.jpg'
        },
        {
          index: 1
          id: 'XC'
          url: 'images/2.jpg'
        },
        {
          index: 2
          id: 'EJ'
          url: 'images/3.jpg'
        }
      ]
      scope.generate = ->
        available = (i for i in [0...scope.choices.length])
        selection = []
        while available.length > 0
          choice = available.splice(
            parseInt(Math.random() * available.length),
            1
          )
          selection.push(scope.choices[choice[0]])
        console.log(selection)
        scope.image1 = selection[0].index
        scope.image2 = selection[1].index
        scope.image3 = selection[2].index
        scope.code = "#{selection[0].id}-#{selection[1].id}-#{selection[2].id}"
  ]
)

app.directive(
  'slotDriver',
  [
    ->
      scope:
        slotSelection: '='
      link: (scope, el) ->
        scope.$watch('slotSelection', (value) ->
          return unless value?
          el[0].scrollTop = 600 * value
        )
  ]
)
