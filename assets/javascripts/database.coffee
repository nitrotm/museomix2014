'use strict'

app = angular.module(
  'database',
  [
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
  ]
)
