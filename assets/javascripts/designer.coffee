'use strict'

app = angular.module(
  'formApp',
  [
    'ngResource'
  ]
)

app.controller(
  'FormController',
  [
    '$scope', '$http',
    (scope, http) ->
      scope.formData = {}

      # Send code to server
      scope.processForm = ->
        http({
          method  : 'POST',
          url     : 'process.php',
          data    : scope.formData,
          headers : { 'Content-Type': 'application/x-www-form-urlencoded' }
        })
  ]
)