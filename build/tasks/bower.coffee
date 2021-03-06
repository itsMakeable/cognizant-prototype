gulp = require('gulp')
$ = require('gulp-load-plugins')(lazy: true)
onError = require('../errors')

# mainBowerFiles = require('main-bower-files')


gulp.task 'install', ->
	return gulp.src(['./bower.json','./package.json'])
		.pipe $.install()

gulp.task 'bower', ->
	jsFilter = $.filter(['**/*.js'])
	cssFilter = $.filter(['**/*.css'])
	files = require('main-bower-files')();
	gulp.src(files)
		.pipe $.plumber(errorHandler: onError)
		.pipe $.filter(['**/*.js'])
		.pipe gulp.dest('./.tmp/js/vendor')
	gulp.src(files)
		.pipe $.plumber(errorHandler: onError)
		.pipe $.filter(['**/*.css'])
		.pipe gulp.dest('./.tmp/css')
