Mkbl = {}

## plugin for jQuery :contains to be case-insensitive
$.expr[':'].Contains = (a, i, m) ->
	(a.textContent or a.innerText or '').toUpperCase().indexOf(m[3].toUpperCase()) >= 0

### SLIDER INIT ###
Mkbl.slideInit = ->
	Mkbl.slider = $('.mkbl-slide-container')
	Mkbl.numberOfSlides = Mkbl.slider.find('.mkbl-slide').length
	Mkbl.activeSlide = 0
	Mkbl.setActiveSlide Mkbl.activeSlide

	$('#js-next-arrow').on 'click', ->
		Mkbl.nextSlide()

	$('.mkbl-slide-container').on 'click', '.slide-after-1', ->
		Mkbl.nextSlide()

	$('#js-prev-arrow').on 'click', ->
		Mkbl.prevSlide()

	$('.mkbl-slide-container').on 'click', '.slide-before-1', ->
		Mkbl.prevSlide()

### SLIDER ROTATE ###
Mkbl.setActiveSlide = (s) ->
	$('.mkbl-slide')
		.removeClass('slide-before-2')
		.removeClass('slide-before-1')
		.removeClass('slide-active')
		.removeClass('slide-after-1')
		.removeClass('slide-after-2')
		# .css('background-image', 'none')

	i = 0
	while i < Mkbl.numberOfSlides
		if i == ((s - 2 + Mkbl.numberOfSlides) % Mkbl.numberOfSlides )
			Mkbl.slider.find('.mkbl-slide').eq(i).addClass 'slide-before-2'
		else if i == ((s - 1 + Mkbl.numberOfSlides) % Mkbl.numberOfSlides)
			Mkbl.slider.find('.mkbl-slide').eq(i).addClass 'slide-before-1'
		else if i == s
			Mkbl.slider.find('.mkbl-slide').eq(i).addClass 'slide-active'
		else if i == ((s+1) % Mkbl.numberOfSlides )
			Mkbl.slider.find('.mkbl-slide').eq(i).addClass 'slide-after-1'
		else if i == ((s + 2) % Mkbl.numberOfSlides )
			Mkbl.slider.find('.mkbl-slide').eq(i).addClass 'slide-after-2'
		i++


Mkbl.nextSlide = ->
	if (!Mkbl.slider.hasClass('locked'))
		Mkbl.slider.addClass('locked')
		Mkbl.activeSlide = (Mkbl.activeSlide - 1 + Mkbl.numberOfSlides) % Mkbl.numberOfSlides
		
		Mkbl.setActiveSlide Mkbl.activeSlide
		setTimeout ->
			Mkbl.slider.removeClass('locked')
		, 800


Mkbl.prevSlide = ->
	if (!Mkbl.slider.hasClass('locked'))
		Mkbl.slider.addClass('locked')
		Mkbl.activeSlide = (Mkbl.activeSlide + 1) % Mkbl.numberOfSlides
		Mkbl.setActiveSlide Mkbl.activeSlide
		setTimeout ->
			Mkbl.slider.removeClass('locked')
		, 800


Mkbl.listFilter = (input, list) ->
	$(input).on 'keyup', (e) ->
		keyCode = e.keyCode or e.which
		if $.inArray(keyCode, [9,13,38,40]) < 0
			filter = $(this).val()
			if filter && filter != ''
				$('.mkbl-form-hint.is-select').removeClass('is-displayed')
				$(list).find('li').removeClass('is-active')
				$(list).find('li:not(:contains(' + filter + '))').removeClass('not-filtered')
				$(list).find('li:contains(' + filter + ')').addClass('not-filtered')
				$(list).find('li.not-filtered').eq(0).addClass('is-active')
				
			else
				$(list).find('li').addClass('not-filtered').removeClass('is-active')
				# if $('.mkbl-main-input').val() != ''
				$('.mkbl-form-hint.is-select').addClass('is-displayed')
				$('.mkbl-form-hint.is-input').removeClass('is-displayed')

# Check array for a value
Mkbl.checkArray = (needle) ->
	if typeof Array::indexOf == 'function'
		indexOf = Array::indexOf
	else
		indexOf = (needle) ->
			i = -1
			index = -1
			i = 0
			while i < @length
				if @[i] == needle
					index = i
					break
				i++
			index

	indexOf.call this, needle


Mkbl.currentField = null
Mkbl.timeout = null
Mkbl.waitToShow = 0;
Mkbl.saveField = (currentField) ->
	hasError = false
	currentFieldVal = $('#enter-' + currentField).find('.mkbl-main-input').val()
	if !$('#enter-' + currentField).find('.mkbl-select-bg').length
		if currentFieldVal == ''
			hasError = true
			$('#enter-' + currentField).find('input').addClass('has-error').trigger('focus')
			$('.mkbl-form-progress-bar').addClass('has-error')
			$('#'+ currentField).removeClass('is-valid')
	else if $('#enter-' + currentField).find('.mkbl-select-bg').length
		options = []
		$('#enter-' + currentField).find('.mkbl-select-option').each ->
			optionText = $(this).text()
			options.push optionText
		if Mkbl.checkArray.call(options, $('#enter-' + currentField).find('.mkbl-main-input').val()) == -1
			hasError = true
			$('#enter-' + currentField).find('input').addClass('has-error').trigger('focus')
			$('.mkbl-form-progress-bar').addClass('has-error')
			$('#'+ currentField).removeClass('is-valid')
	
	if (!hasError)
		$('#' + currentField + ' .mkbl-subinput').text(currentFieldVal)
		$('#'+ currentField)
			.removeClass('is-active')
			.removeClass('is-typing')
			.addClass('is-filled')
			.addClass('is-valid')
		$('.mkbl-form-progress-bar')
			.removeClass('has-error')

		$('#enter-' + currentField).find('.mkbl-select-bg').removeClass('is-open')
		$('#'+ currentField).find('.mkbl-select-bg').removeClass('is-open')
		if $('#enter-' + currentField).find('.mkbl-select-bg').length
			setTimeout (->
				$('#enter-' + currentField).addClass('is-hidden')
			), 400
			Mkbl.waitToShow = 400
		else
			$('#enter-' + currentField).addClass('is-hidden')
			Mkbl.waitToShow = 0
		Mkbl.setProgress()

	return !hasError


Mkbl.prepareField = (nextField) ->
	$('.mkbl-form-complete').removeClass('is-active')
	$('.mkbl-form-hint.is-select').removeClass('is-displayed')
	$('.mkbl-form-hint.is-input').removeClass('is-displayed')
	if $('#enter-' + nextField).find('.mkbl-select-bg').length
		if Mkbl.currentField != nextField
			setTimeout (->
				$('#enter-' + nextField).removeClass('is-hidden')
				setTimeout (->
					$('#enter-' + nextField).find('.mkbl-main-input').trigger('focus')
					$('.mkbl-form-hint.is-select').addClass('is-displayed')
					Mkbl.listFilter('.mkbl-sselect','.mkbl-select-bg.is-open')
					$('#enter-'+ nextField).find('.mkbl-select-bg').addClass('is-open')
				), 1
			), Mkbl.waitToShow
	else
		setTimeout (->
			$('#enter-' + nextField).removeClass('is-hidden')
			setTimeout (->
				$('#enter-' + nextField)
					.find('.mkbl-main-input')
					.trigger('focus')
				), 1
		), Mkbl.waitToShow
	
	$('#' + nextField)
		.addClass('is-active')
		.removeClass('is-clean')
	
	if $('#enter-' + nextField).find('.mkbl-select-bg').length
		Mkbl.waitToShow = 400;
	else
		Mkbl.waitToShow = 0;
	Mkbl.currentField = nextField


Mkbl.moveToField = (nextField) ->
	if Mkbl.currentField == nextField
		return 
	currentF = Mkbl.currentField
	success = true
	if currentF != null && $('#' + currentF).hasClass('is-dirty')
		success = Mkbl.saveField(currentF)
	else
		if $('#enter-' + currentF).find('.mkbl-select-bg').length
			$('#enter-' + currentF).find('.mkbl-select-bg').removeClass('is-open')
			$('#'+ currentF).find('.mkbl-select-bg').removeClass('is-open')
			setTimeout (->
				$('#enter-' + currentF).addClass('is-hidden')
			), 400
			Mkbl.waitToShow = 400
		else
			$('#enter-' + currentF).addClass('is-hidden')
			Mkbl.waitToShow = 0
		$('#'+ currentF)
			.removeClass('is-active')
			.removeClass('is-typing')
			.addClass('is-filled')
	if (success)
		Mkbl.prepareField(nextField)


Mkbl.requestNextField = ->
	if Mkbl.currentField != null
		success = Mkbl.saveField(Mkbl.currentField)
		if (success)
			if $('.mkbl-form-subfields .mkbl-fieldset.is-valid').length == Mkbl.progressDenominator
				Mkbl.showSubmit()
			else
				nextField = $('.mkbl-form-subfields .mkbl-fieldset.is-valid').last().next().attr('id')
				Mkbl.prepareField(nextField)
	else
		Mkbl.prepareField 'field-name'


Mkbl.showSubmit = ->
	$('.mkbl-select-bg').removeClass('is-open')
	$('.mkbl-form-hint.is-select').removeClass('is-displayed')
	$('.mkbl-form-hint.is-input').removeClass('is-displayed')
	$('.mkbl-button').addClass('is-active').trigger('focus')
	setTimeout (->
		$('.mkbl-form-main-field fieldset').addClass('is-hidden')
		$('.mkbl-form-complete').addClass('is-active')
	), 400


### This sets the progress bar after entering a value in the form ###
Mkbl.setProgress = ->
	setTimeout (->
		progressFilled = $('.mkbl-form-subfields .mkbl-fieldset.is-filled').length
		progressActive = $('.mkbl-form-subfields .mkbl-fieldset.is-filled.is-active').length
		progressDividend = progressFilled - progressActive
		$('.mkbl-form-progress-bar-progress').css('width', ((progressDividend/Mkbl.progressDenominator) * 100) + '%')
	), 1
	

Mkbl.formInit = ->
	Mkbl.prepareField('field-name')
	Mkbl.progressDenominator = $('.mkbl-form-subfields .mkbl-fieldset').length
	$('.mkbl-form-subfields .mkbl-fieldset').on 'click', ->
		Mkbl.moveToField( $(this).attr('id') )

	$('.mkbl-main-input').on 'keydown', ->
		thisField = $(this).closest('fieldset').attr('id').substring(6)
		$('#' + thisField).addClass('is-dirty')
		$('.mkbl-form-main-field .mkbl-fieldset').find('input').removeClass('has-error')
		$('.mkbl-form-hint.is-input').addClass('is-displayed')
		$('.mkbl-form-progress-bar').removeClass('has-error')
		### This animates the input dots ###
		deanimateEllipse = ->
			$('#' + thisField).removeClass('is-typing')
		animateEllipse = ->
			$('#' + thisField).addClass('is-typing')

		animateEllipse()
		if Mkbl.timeout
			clearTimeout Mkbl.timeout
			Mkbl.timeout = null
		Mkbl.timeout = setTimeout(deanimateEllipse, 1500)

	### removes hints to selects ###
	$('.mkbl-main-input').on 'blur', ->
		$('.mkbl-form-hint.is-input').removeClass('is-displayed')

	### the form button trigger ###
	$('.js-form-next').on 'click', (e) ->
		Mkbl.requestNextField();
		return
		thisField = $(this).closest('fieldset').attr('id').substring(6)

	$(window).on 'keydown', (e) ->
		thisField = $('#enter-' + Mkbl.currentField).attr('id').substring(6)
		# $('.mkbl-form-button').prop('disabled',true)
		keyCode = e.keyCode or e.which
		if keyCode == 9
			e.preventDefault()
		### Tab and Submit ###
		if keyCode == 9 || keyCode == 13
			if !$('.mkbl-form-button').is(':focus')
				e.preventDefault()
				if $('.mkbl-form').find('.mkbl-select-bg.is-open .is-active').length
					$('#enter-' + Mkbl.currentField + ' .mkbl-main-input').val($('.mkbl-select-bg.is-open .is-active').text())
				setTimeout (->
					Mkbl.requestNextField();
				), 1
		### Up Arrow ###
		if keyCode == 40
			e.preventDefault()
			$('.mkbl-form-hint.is-select').removeClass('is-displayed')
			$('.mkbl-form-hint.is-input').addClass('is-displayed')
			
			if $('.mkbl-form').find('.mkbl-select-bg.is-open .is-active').length
				selectActive = $('.mkbl-form').find('.mkbl-select-bg.is-open .is-active')
				selectActive.removeClass('is-active')
				selectActive.next().addClass('is-active')
				$('#enter-' + Mkbl.currentField).find('input').removeClass('has-error')
				$('.mkbl-form-progress-bar').removeClass('has-error')
			else
				selectActive = $('.mkbl-form').find('.mkbl-select-bg.is-open .mkbl-select-option:first-of-type')
				$('.mkbl-select-bg.is-open .mkbl-select-option:first-of-type').addClass('is-active')
			$('#enter-' + Mkbl.currentField + ' .mkbl-main-input').val(selectActive.next().text())
		### Down Arrow ###
		if keyCode == 38
			e.preventDefault()
			$('.mkbl-form-hint.is-select').removeClass('is-displayed')
			$('.mkbl-form-hint.is-input').addClass('is-displayed')

			if $('.mkbl-form').find('.mkbl-select-bg.is-open .is-active').length
				selectActive = $('.mkbl-form').find('.mkbl-select-bg.is-open .is-active')
				selectActive.removeClass('is-active')
				selectActive.prev().addClass('is-active')
				$('#enter-' + Mkbl.currentField).find('input').removeClass('has-error')
				$('.mkbl-form-progress-bar').removeClass('has-error')
			else
				selectActive = $('.mkbl-form').find('.mkbl-select-bg.is-open .mkbl-select-option:last-of-type')
				$('.mkbl-select-bg.is-open .mkbl-select-option:last-of-type').addClass('is-active')
			$('#enter-' + Mkbl.currentField + ' .mkbl-main-input').val(selectActive.prev().text())


	$('.mkbl-select-option').on 'click', ->
		selectOption = $(this).text()
		$('#enter-' + Mkbl.currentField + ' .mkbl-sselect').val(selectOption)
		Mkbl.requestNextField()

	
	$('.mkbl-select-option').on 'mouseover', ->
		$('.mkbl-select-option').addClass('not-filtered').removeClass('is-active')
		$(this).addClass('is-active')
		$('#enter-' + Mkbl.currentField + ' .mkbl-main-input').val($(this).text())
		$('#enter-' + Mkbl.currentField).find('input').removeClass('has-error')
		$('.mkbl-form-progress-bar').removeClass('has-error')


$ ->	
	Mkbl.slideInit()
	Mkbl.formInit()
	$('.center').addClass('is-on')

	
