###global -$ ###

'use strict'
# generated on 2015-03-18 using generator-gulp-webapp 0.3.0
gulp = require('gulp')

$ = require('gulp-load-plugins')()

browserSync = require('browser-sync')

include = require('gulp-include')

reload = browserSync.reload


gulp.task 'styles', ->
  gulp.src('app/styles/main.sass')
    .pipe($.sourcemaps.init())
      .pipe($.sass(
        indentedSyntax: true
        outputStyle: 'nested'
        precision: 10
        includePaths: [ '.' ]
        onError: console.error.bind(console, 'Sass error:')))
    .pipe($.postcss([ require('autoprefixer-core')(browsers: [ 'last 1 version' ]) ]))
    .pipe($.autoprefixer(
      browsers: [ 'last 2 versions' ]
      cascade: false))
    .pipe($.sourcemaps.write()).pipe(gulp.dest('.tmp/styles'))
    .pipe reload(stream: true)

gulp.task 'jshint', ->
  gulp.src('app/scripts/**/*.js')
    .pipe(reload(
      stream: true
      once: true))
    .pipe($.jshint())
    .pipe($.jshint.reporter('jshint-stylish'))
    .pipe $.if(!browserSync.active, $.jshint.reporter('fail'))

gulp.task 'html', [ 'styles' ], ->
  assets = $.useref.assets(searchPath: ['.tmp','app','.'])
  gulp.src('app/*.html')
    .pipe(assets)
    .pipe($.if('*.js', $.uglify()))
    .pipe($.if('*.css', $.csso()))
    .pipe(assets.restore())
    .pipe($.useref())
    .pipe($.if('*.html', $.minifyHtml(
      conditionals: true
      loose: true))).pipe gulp.dest('dist')

gulp.task 'images', ->
  gulp.src('app/images/**/*')
    .pipe($.cache($.imagemin(
      progressive: true
      interlaced: true
      svgoPlugins: [ { cleanupIDs: false } ])))
    .pipe gulp.dest('dist/images')

gulp.task 'fonts', ->
  gulp.src(require('main-bower-files')(filter: '**/*.{eot,svg,ttf,woff,woff2}')
    .concat('app/fonts/**/*'))
    .pipe(gulp.dest('.tmp/fonts'))
    .pipe gulp.dest('dist/fonts')

gulp.task 'extras', ->
  gulp.src([
    'app/*.*'
    '!app/*.html'
  ], dot: true).pipe gulp.dest('dist')

gulp.task 'clean', require('del').bind(null, [
  '.tmp'
  'dist'
])

gulp.task 'slim', ->
  gulp.src('./app/slim/index.slim')
    .pipe(include())
    .pipe($.slim(pretty: true, options: "attr_list_delims={'(' => ')', '[' => ']'}")
      .on('error', console.error.bind(console, 'SLIM error:')))
    .pipe(gulp.dest('./app/'))
    .pipe reload(stream: true)
  return

gulp.task 'coffee', ->
  gulp.src('app/scripts/coffee/main.coffee')
    .pipe($.sourcemaps.init())
    .pipe($.coffee(bare: true).on('error', console.error.bind(console, 'COFFEE error:')))
    .pipe($.sourcemaps.write())
    .pipe gulp.dest('app/scripts')
    .pipe reload(stream: true)
  return

gulp.task 's', [
  'slim'
  'coffee'
  'styles'
  'fonts'
], ->
  browserSync
    notify: false
    open: false
    port: 9000
    server:
      baseDir: [
        '.tmp'
        'app'
      ]
      routes: '/bower_components': 'bower_components'
  # watch for changes
  gulp.watch([
    'app/*.html'
    'app/scripts/**/*.js'
    'app/images/**/*'
    '.tmp/fonts/**/*'
  ]).on 'change', reload
  gulp.watch 'app/scripts/coffee/**/*.coffee', [ 'coffee' ]
  gulp.watch 'app/slim/**/*.slim', [ 'slim' ]
  gulp.watch 'app/styles/**/*.sass', [ 'styles' ]
  gulp.watch 'app/fonts/**/*', [ 'fonts' ]
  gulp.watch 'bower.json', [
    'wiredep'
    'fonts'
  ]
  return

# inject bower components
gulp.task 'wiredep', ->
  wiredep = require('wiredep').stream
  gulp.src('app/styles/*.sass').pipe(wiredep(ignorePath: /^(\.\.\/)+/)).pipe gulp.dest('app/styles')
  gulp.src('app/*.html').pipe(wiredep(ignorePath: /^(\.\.\/)*\.\./)).pipe gulp.dest('app')
  return

gulp.task 'build', [
  'jshint'
  'html'
  'images'
  'fonts'
  'extras'
], ->
  gulp.src('dist/**/*').pipe $.size(
    title: 'build'
    gzip: true)

gulp.task 'default', [ 'clean' ], ->
  gulp.start 'build'
  return
