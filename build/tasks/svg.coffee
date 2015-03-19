gulp = require('gulp')
$ = require('gulp-load-plugins')(lazy: true)
onError = require('../errors')

gulp.task 'svgmin', ['clean:svg'], ->
	gulp.src('src/svg/**/*.svg')
		.pipe $.plumber(errorHandler: onError)
		.pipe $.svgmin()
		.pipe gulp.dest('app/svg/')
	return gulp.src('src/svg/**/*.svg')
		.pipe $.plumber(errorHandler: onError)
		.pipe $.svgfallback()
		.pipe gulp.dest('app/img/')

gulp.task 'symbols', ['svgmin'], ->
	return gulp.src('src/svg/symbols/*.svg')
		.pipe $.plumber(errorHandler: onError)
		.pipe $.svgmin()
		.pipe $.cheerio(
			run: (find) ->
				find('[fill]').attr 'fill', 'currentColor'
				
			parserOptions:
				xmlMode: true
		)
		.pipe $.svgstore(
			fileName: 'symbols.svg'
			inlineSvg: true
		)

		.pipe gulp.dest('src/jade/includes')
	# gulp.src('src/svg/symbols/*.svg')
	#	.pipe($.plumber(errorHandler: onError))
	# 	.pipe($.replace(/(#010101)/g, 'currentColor'))
	# 	.pipe($.svgmin())
	# 	.pipe gulp.dest('app/svg/')

gulp.task 'svg', ['symbols'], ->
	return gulp.src('src/jade/includes/symbols.svg')
		.pipe $.cheerio(
			run: (find) ->
				find('svg').css 
					position: 'absolute'
					left: '-9999px'
			)
		.pipe gulp.dest('src/jade/includes')