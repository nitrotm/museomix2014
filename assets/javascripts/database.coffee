'use strict'

app = angular.module(
  'database',
  [
    'ngResource'
  ]
)

app.factory(
  'database',
  [
    '$http'
    ($http) ->
      rows: $http.get(
          '/dataset'
        ).then(
          (data) ->
            rows = data.data
            for i in [0...rows.length]
              rows[i].index = i
            rows
        )
    # {
    #   id: 'HA'
    #   url: 'images/a2.jpg'
    # },
    # {
    #   id: 'XC'
    #   url: 'images/a3.jpg'
    # },
    # {
    #   id: 'EJ'
    #   url: 'images/a4.jpg'
    # },
    # {
    #   id: 'DA'
    #   url: 'images/a6.jpg'
    # },
    # {
    #   id: 'KN'
    #   url: 'images/a7.jpg'
    # }
  ]
)
