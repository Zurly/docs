###
#
# The Gruntfile for the Spark documentation
# Created by Zach Supalla
# https://www.spark.io/
#
# Use this gruntfile to:
# - Assemble the static site (grunt build)
# - Deploy locally for development (grunt server)
#
# Copyright (c) 2013 Spark Labs, Inc.
# Licensed under a Creative Commons Attribution-Sharealike 3.0 License.
#
###

module.exports = (grunt) ->

  gruntConfig =

    config:
      src: 'src'
      dist: 'build'
      content: 'src/content'
      layouts: 'src/layouts'

    assemble:
      # ASSEMBLE!!!
      options:
        flatten: true
        assets: '<%= config.dist %>/assets'
        layoutdir: '<%= config.src %>/layouts'
        layout: 'default.hbs'
        plugins: ['assemble-contrib-permalinks', 'plugins/verbose/verbose.js',
          'plugins/toc/toc.js']
        permalinks:
          structure: ':basename/index:ext'
        toc:
          id: 'toc'
      docs:
        options:
          ext: '.html'
          layout: 'docs.hbs'
        files: [
          {
            expand: true
            cwd: '<%= config.content %>'
            src: ['*.md']
            dest: '<%= config.dist %>'
          }
        ]


    # 'gh-pages':

    clean:
      dest: ['<%= config.dist %>/**']

    copy:
      start:
        dest: '<%= config.dist %>/index.html'
        src: '<%= config.dist %>/start/index.html'
      assets:
        expand: true
        dest: '<%= config.dist %>/assets/'
        cwd: '<%= config.src %>/assets/'
        src: '**'

    watch:
      content:
        files: ['<%= config.content %>/*.md', '<%= config.layouts %>/*.hbs']
        tasks: ['build']
      stylesheets:
        files: ['<%= config.src %>/stylesheets/*.less']
        tasks: ['less']
      assets:
        files: ['<%= config.src %>/assets/**']
        tasks: ['copy']
      livereload:
        options:
          livereload: '<%= connect.options.livereload %>'
        files: [
          '<%= config.dist %>/**/*.html',
          '<%= config.dist %>/assets/**/*.css',
          '<%= config.dist %>/assets/**/*.js',
          '<%= config.dist %>/assets/**/*.{png,jpg,jpeg,gif,webp,svg}'
        ]

    connect:
      options:
        port: 3232
        livereload: 35729
        hostname: 'localhost'
      livereload:
        options:
          open: true
          base: ['<%= config.dist %>']

    coffeelint:
      grunt: ['Gruntfile.coffee']

    less:
      docs:
        files:
          '<%= config.dist %>/assets/css/style.css':
            '<%= config.src %>/stylesheets/style.less'

    compress:
      main:
        options:
          archive: 'docs.zip'
        files: [{
          expand: true
          cwd: '<%= config.dist %>/'
          src: ['**']
        }]

    rename:
      main:
        dest: '<%= config.dist %>/assets/docs.zip'
        src: 'docs.zip'

    replace:
      index:
        src: ['<%= config.dist %>/index.html']
        overwrite: true
        replacements:[{
          from: '../'
          to: ''
        }]


  grunt.initConfig gruntConfig

  grunt.loadNpmTasks 'assemble'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-jshint'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-contrib-compress'
  grunt.loadNpmTasks 'grunt-rename'
  grunt.loadNpmTasks 'grunt-text-replace'

  grunt.registerTask 'server', ['build', 'connect:livereload', 'watch']
  grunt.registerTask 'build', ['test', 'clean', 'assemble', 'less',
    'copy', 'replace']
  grunt.registerTask 'archive', ['compress', 'rename']
  grunt.registerTask 'deploy', ['build', 'archive']
  grunt.registerTask 'test', ['coffeelint']
