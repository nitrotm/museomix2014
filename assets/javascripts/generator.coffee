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
      generate = (print = false) ->
        available = (i for i in [0...scope.choices.length])
        selection = []
        while available.length > 0
          choice = available.splice(
            parseInt(Math.random() * available.length),
            1
          )
          selection.push(scope.choices[choice[0]])
        $('#music')[0].play()
        scope.image1 = selection[0].index
        setTimeout(
          ->
            scope.image2 = selection[1].index
            scope.$digest()
          ,
          500
        )
        setTimeout(
          ->
            scope.image3 = selection[2].index
            scope.$digest()

            if print
              $http.get(
                '/print',
                params:
                  id1: selection[0].id
                  text1: selection[0].title
                  description1: selection[0].description
                  room1: selection[0].room
                  id2: selection[1].id
                  text2: selection[1].title
                  description2: selection[1].description
                  room2: selection[1].room
                  id3: selection[2].id
                  text3: selection[2].title
                  description3: selection[2].description
                  room3: selection[2].room
              )
          ,
          1000
        )

      database.rows.then(
        (data) ->
          scope.choices = data
          generate(true)
      )

      listenTrigger = ->
        $http.get(
          '/trigger',
          timeout: 5000
        ).then(
          (data) ->
            generate(true) if parseInt(data.data) == 1
            listenTrigger()
          ,
          (e) ->
            setTimeout(
              -> listenTrigger()
              ,
              500
            )
        )
      listenTrigger()
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

app.directive(
  'slotDriverGl',
  [
    'database'
    (database) ->
      scope:
        slotSelection: '='
      link: (scope, el) ->
        $(el).children().remove()

        width = $(el).innerWidth()
        height = $(el).innerHeight()
        ratio = width / height

        renderer = new THREE.WebGLRenderer(
          antialias: true
          alpha: true
        )
        $(el).append(renderer.domElement)

        camera = new THREE.PerspectiveCamera(40, ratio, 1, 1000)
        camera.position.z = 10

        renderer.setSize(width, height)

        scene = new THREE.Scene()

        texture = THREE.ImageUtils.loadTexture('images/texture3.jpg')
        texture.wrapS = texture.wrapT = THREE.RepeatWrapping

        cylinderWidth = 8
        cylinderRadius = 15

        cylinderGeometry = new THREE.CylinderGeometry(
          cylinderRadius,
          cylinderRadius,
          cylinderWidth,
          30,
          1,
          true
        )
        for index in [0...cylinderGeometry.faces.length]
          face = cylinderGeometry.faces[index]
          a = cylinderGeometry.vertices[face.a]
          b = cylinderGeometry.vertices[face.b]
          c = cylinderGeometry.vertices[face.c]
          getcoordx = (v) ->
            1.0 - (v.y / cylinderWidth + 0.5)
          getcoordy = (v) ->
            1.0 - (Math.atan2(v.z, v.x) / Math.PI / 2 + 0.5)
          xa = getcoordx(a)
          xb = getcoordx(b)
          xc = getcoordx(c)
          ya = getcoordy(a)
          yb = getcoordy(b)
          yc = getcoordy(c)
          if Math.abs(ya - yb) > 0.3
            if ya > yb
              yb += 1.0
            else
              ya += 1.0
          if Math.abs(ya - yc) > 0.3
            if ya > yc
              yc += 1.0
            else
              ya += 1.0
          if Math.abs(yb - yc) > 0.3
            if yb > yc
              yc += 1.0
            else
              yb += 1.0
          for uvs in cylinderGeometry.faceVertexUvs
            uvs[index][0].x = xa
            uvs[index][0].y = ya
            uvs[index][1].x = xb
            uvs[index][1].y = yb
            uvs[index][2].x = xc
            uvs[index][2].y = yc
        cylinderGeometry.computeFaceNormals()
        cylinderGeometry.computeVertexNormals()

        cylinderMaterial = new THREE.MeshPhongMaterial(
          # wireframe: true
          # color: 0xffffff
          shininess: 255
          map: texture
        )
        cylinderMesh = new THREE.Mesh(cylinderGeometry, cylinderMaterial)
        cylinderMesh.translateZ(-25)
        cylinderMesh.rotateOnAxis(
          new THREE.Vector3(0, 0, 1),
          90 * Math.PI / 180
        )

        scene.add(cylinderMesh)

        scene.add(new THREE.AmbientLight(0xaaaaaa))
        light = new THREE.DirectionalLight(0xe0e0e0, 0.2)
        light.position.set(8, 5, 20)
        light.target = cylinderMesh
        scene.add(light)

        active = true
        baseAngle = -107
        t0 = 0
        t1 = 1
        t2 = 7
        t3 = 8
        x0 = 0
        x1 = 0
        x2 = 0
        x3 = 0
        clock = null
        render = ->
          # delta = clock.getDelta()
          t = clock?.getElapsedTime()
          if clock && t < t3
            angle = 0
            angle += (t - t1) * (t - t2) * (t - t3) / (t0 - t1) / (t0 - t2) / (t0 - t3) * x0
            angle += (t - t0) * (t - t2) * (t - t3) / (t1 - t0) / (t1 - t2) / (t1 - t3) * x1
            angle += (t - t0) * (t - t1) * (t - t3) / (t2 - t0) / (t2 - t1) / (t2 - t3) * x2
            angle += (t - t0) * (t - t1) * (t - t2) / (t3 - t0) / (t3 - t1) / (t3 - t2) * x3
            cylinderMesh.rotation.x = (baseAngle - angle) * Math.PI / 180
          else
            cylinderMesh.rotation.x = (baseAngle - x2) * Math.PI / 180
            clock = null

          renderer.render(scene, camera)
          requestAnimationFrame(render)
        render()

        start = (x) ->
          x1 = 360 / 13 * x + 360 * 1
          x2 = 360 / 13 * x + 360 * 9
          x3 = 360 / 13 * x + 360 * 10
          clock = new THREE.Clock()

        scope.$watch(
          'slotSelection',
          (value) -> start(value)
        )
  ]
)
