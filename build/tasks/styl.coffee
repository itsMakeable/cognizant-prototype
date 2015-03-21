gulp = require('gulp')
$ = require('gulp-load-plugins')(lazy: true)
onError = require('../errors')
browserSync = require('browser-sync')

# Stylus Plugins
nib = require('nib')
del = require('del')
axis = require('axis')
rupture = require('rupture')
jeet = require('jeet')


gulp.task 'styl', ->
	# compress: true
	# .pipe(autoprefixer())
	return gulp.src('src/styl/index.styl')
		.pipe $.plumber(errorHandler: onError)
		.pipe $.accord('stylus', {
			use: [
				axis()
				jeet()
				rupture()
				nib()
			]
			include: ['src/styl']
			url: true
			'include css': true
		})
		.pipe $.rename('index.css')
		.pipe gulp.dest('./.tmp/css')

gulp.task 'copycss', ->
	return gulp.src('./src/css/**/*.css')
		.pipe $.order [
			'flexslider.css'
			'slider.css'
		]
		.pipe $.concat('css.css')
		# .pipe($.cssmin())
		.pipe gulp.dest('./src/styl')
		.pipe(browserSync.reload({stream:true}))

gulp.task 'css', ->
	return gulp.src('./.tmp/css/*.css')
		# .pipe $.importCss()
		# .pipe $.order [
		# 	'swiper.css'
		# 	'index.css'
		# ]
		.pipe $.concat('index.css')
		# .pipe $.cssmin()
		.pipe $.csscomb()
		.pipe gulp.dest('app')
		.pipe(browserSync.reload({stream:true}))

gulp.task 'styldoc', ->
	return gulp.src('./.tmp/index.css')
		# .pipe $.plumber(errorHandler: onError)
		.pipe $.styledocco(
			out: 'docs/styleguide'
			name: 'Wooftagg'
			# preproccesor: 'stylus -u axis() jeet() rupture() nib() --import src/styl/**/*.styl'
			# include: ['app/index.css']
		)
