gulp = require('gulp')
$ = require('gulp-load-plugins')(lazy: true)

# NICE ERRORS
(err) ->
	$.notify.onError(
		title: 'Gulp'
		subtitle: 'Failure!'
		message: 'Error: <%= error.message %>'
		sound: 'Beep'
	) err
	@emit 'end'
	return