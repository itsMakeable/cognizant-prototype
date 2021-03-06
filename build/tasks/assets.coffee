gulp = require('gulp')
$ = require('gulp-load-plugins')(lazy: true)
onError = require('../errors')


gulp.task 'img', ->
  return gulp.src([
    'src/img/**/*.jpg'
    'src/img/**/*.png'
  ])
  	.pipe($.plumber(errorHandler: onError))
  	.pipe($.imagemin())
  	.pipe gulp.dest('app/img/')


gulp.task 'font', ->
  return gulp.src([
    'src/font/*.ttf',
    'src/font/*.otf'
  ])
  	.pipe($.plumber(errorHandler: onError))
  	.pipe($.cssfont64())
  	.pipe gulp.dest('./.tmp/css')


gulp.task 'static', ->
  return gulp.src(['src/static/**'], { base: 'src/static/'})
  	.pipe gulp.dest('app/')

gulp.task 'cson', ->
  gulp.src([ 'src/cson/*.cson' ])
    .pipe $.cson()
    .pipe gulp.dest('app')