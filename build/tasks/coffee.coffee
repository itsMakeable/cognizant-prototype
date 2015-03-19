gulp = require('gulp')
$ = require('gulp-load-plugins')(lazy: true)
onError = require('../errors')
browserSync = require('browser-sync')
stylish = require('jshint-stylish')

gulp.task 'coffee', ->
	gulp.src([
		'src/coffee/**/**/*.coffee'
	])
		.pipe $.plumber(errorHandler: onError)
		.pipe($.order([
			'**/plugins/*'
		]))
		.pipe $.concat('app.js')
		.pipe $.accord('coffee-script')
		.pipe $.jshint()
		.pipe $.jshint.reporter(stylish)
		.pipe gulp.dest('./.tmp/js')


gulp.task 'js', ->
	gulp.src(['./.tmp/js/vendor/*.js','./.tmp/js/*.js','./src/js/*.js'])
		.pipe $.order [
			"**/jquery.js"
			"app.js"
		]
		# .pipe($.accord('uglify-js', {
		# 	beautify: true
		# 	mangle: false
		# }))
		.pipe $.concat 'app.js'
		.pipe gulp.dest 'app'
		.pipe browserSync.reload({stream:true})