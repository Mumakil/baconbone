module.exports = (grunt) ->
  
  require('load-grunt-tasks')(grunt)
  
  grunt.initConfig
    
    pkg: grunt.file.readJSON('package.json')
    
    coffee:
      test:
        options: 
          join: true
          sourceMap: true
          sourceMapDir: 'test/maps/'
        files: 
          'test/baconbone_test.js': [
            'test/baconbone_test.coffee'
            'test/*_test.coffee'
          ]
      lib: 
        options:
          join: true
          sourceMap: true
          sourceMapDir: 'lib/maps/'
        files: 
          'lib/baconbone.js': [
            'src/backbone_extensions.coffee'
            'src/model_extensions.coffee'
            'src/baconbone.coffee'
            'src/baconbone_view.coffee'
            'src/baconbone_model_view.coffee'
            'src/baconbone_collection_view.coffee'
          ]
          'lib/backbone_extensions.js': [
            'src/backbone_extensions.coffee'
            'src/model_extensions'
          ] 
      
    jasmine: 
      all:
        src: 'lib/baconbone.js'
        options:
          specs: 'test/*_test.js'
          vendor: [
            'bower_components/jquery/dist/jquery.js'
            'bower_components/lodash/dist/lodash.js'
            'bower_components/backbone/backbone.js'
            'bower_components/bacon/dist/Bacon.js'
          ]
          summary: true
          display: 'short'
    
    watch: 
      lib: 
        files: ['src/*.coffee']
        tasks: ['coffee:lib', 'jasmine']
      test:
        files: ['test/*.coffee']
        tasks: ['coffee:test', 'jasmine']
  
  grunt.registerTask 'test', ['coffee', 'jasmine']
  grunt.registerTask 'build', ['coffee:lib']
  
  grunt.registerTask 'default', ['build']