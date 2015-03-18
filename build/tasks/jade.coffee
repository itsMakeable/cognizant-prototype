gulp = require('gulp')
$ = require('gulp-load-plugins')(lazy: true)
onError = require('../errors')
browserSync = require('browser-sync')

gulp.task 'jade', ->
	return gulp.src(['src/jade/**/*.jade'])
		.pipe $.plumber(errorHandler: onError)
		.pipe $.accord('jade')
		.pipe $.rename('index.html')
		.pipe gulp.dest('app')