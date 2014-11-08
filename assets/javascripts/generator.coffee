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
      scope.code = 'HA-XC-EJ'
      scope.image1 = 0
      scope.image2 = 1
      scope.image3 = 2
  ]
)

app.directive(
  'slotDriver',
  [
    ->
      scope:
        slotSelection: '='
      link: (scope, el) ->
        scope.$watch('selection', (value) ->
          el[0].scrollTop = 600 * value
          console.log(value)
        )
  ]
)
