Mkbl = {}

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
		# else
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


Mkbl.currentField = null
Mkbl.timeout = null

Mkbl.saveField = (currentField) ->
	hasError = false
	currentFieldVal = $('#enter-' + currentField).find('.mkbl-main-input').val()
	if currentFieldVal == ''
		# || !$('#enter-' + currentField).hasClass('is-clean')
		console.log 'this'
		hasError = true
		$('#enter-' + currentField).find('input').trigger('focus')
		$('#enter-' + currentField).find('input')
			.addClass('has-error')
	else
		$('#' + currentField + ' .mkbl-subinput')
			.html(currentFieldVal)
		$('#enter-' + currentField)
			.addClass('is-hidden')
		$('#'+ currentField)
			.removeClass('is-active')
			.removeClass('is-typing')
			.addClass('is-filled')
	return !hasError

Mkbl.prepareField = (nextField) ->
	$('#enter-' + nextField)
		.removeClass('is-hidden')
	if $('#enter-' + nextField).find('.mkbl-select-bg').length
		if !$('#enter-' + nextField).prev().find('.mkbl-select-bg').length
			setTimeout (->
				$('#enter-' + nextField).find('.mkbl-select-bg').addClass('is-open')
				$('.mkbl-form-hint.is-select').addClass('is-displayed')
				return
			), 1
		else
			$('#enter-' + nextField).find('.mkbl-select-bg').addClass('is-open')
			$('.mkbl-form-hint.is-select').addClass('is-displayed')
	$('#' + nextField)
		.addClass('is-active')
		.removeClass('is-clean')
	$('#enter-' + nextField)
		.find('.mkbl-main-input')
		.trigger('focus')
	Mkbl.currentField = nextField
	Mkbl.setProgress()

Mkbl.moveToField = (nextField) ->
	if Mkbl.currentField == nextField
		return 
	
	if Mkbl.currentField != null
		success = Mkbl.saveField(Mkbl.currentField)

	if (success)

		Mkbl.prepareField(nextField)

	Mkbl.setProgress()

### This sets the progress bar after entering a value in the form ###
Mkbl.setProgress = ->
	progressDenominator = $('.mkbl-form-subfields .mkbl-fieldset').length
	progressDividend = $('.mkbl-form-subfields .mkbl-fieldset.is-filled').length
	$('.mkbl-form-progress-bar-progress').css('width', ((progressDividend/progressDenominator) * 100) + '%')

Mkbl.formInit = ->

	$('.mkbl-form-subfields .mkbl-fieldset').on 'click', ->
		nextField = $(this).attr('id')
		Mkbl.moveToField nextField

	$('.mkbl-main-input').on 'keydown', ->
		thisField = $(this).closest('fieldset').attr('id').substring(6)

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
		if ($(this).closest('fieldset').is(':last-of-type'))
			console.log 'this is the last form field'
			success = Mkbl.saveField(thisField)
			if (success) 
				$('.mkbl-button').trigger('focus')
		else
			$('.mkbl-form-subfields fieldset.is-active').next().click()

	$('.mkbl-main-input').on 'keydown', (e) ->
		thisField = $(this).closest('fieldset').attr('id').substring(6)
		$('.mkbl-form-hint.is-input').addClass('is-displayed')
		keyCode = e.keyCode or e.which
		# tab or enter
		if keyCode == 9 || keyCode == 13
			e.preventDefault()

			if ($(this).closest('fieldset').is(':last-of-type'))
				success = Mkbl.saveField(thisField)
				if (success) 
					$('.mkbl-button').trigger('focus')
			else
				nextField = $('.mkbl-form-subfields fieldset.is-active').next().attr('id')
				Mkbl.moveToField nextField
		# Down
		if keyCode == 40
			console.log 'up'
			e.preventDefault()
			$('.mkbl-form-hint.is-select').removeClass('is-displayed')
			$('.mkbl-form-hint.is-input').addClass('is-displayed')
			selectActive = $('.mkbl-form').find('.mkbl-select-bg.is-open .is-active')
			selectActive.removeClass('is-active')
			selectActive.next().addClass('is-active')

		# Up
		if keyCode == 38
			console.log 'down'
			e.preventDefault()
			$('.mkbl-form-hint.is-select').removeClass('is-displayed')
			$('.mkbl-form-hint.is-input').addClass('is-displayed')
			selectActive = $('.mkbl-form').find('.mkbl-select-bg.is-open .is-active')
			selectActive.removeClass('is-active')
			selectActive.prev().addClass('is-active')

	$(window).on 'keydown', (e) ->
		keyCode = e.keyCode or e.which
		if keyCode == 9 || keyCode == 13
			e.preventDefault()
			if $('.mkbl-form').find('.mkbl-select-bg.is-open .is-active').length
				console.log('option has been selected')
				# From Kyla: The following 3 lines are probably incorrect and should be deleted
				selectOption = $('.mkbl-select-bg.is-open .is-active').text()
				$('.mkbl-sselect').val(selectOption)
				$('.mkbl-form-subfields fieldset.is-active').next().click()
				$('.mkbl-sselect').val('')
				if ($(this).closest('fieldset').is(':last-of-type'))
					console.log 'this is the last form field'

	$('.mkbl-select-option').on 'click', ->
		console.log('option has been selected')
		# From Kyla: The following 3 lines are probably incorrect and should be deleted
		$('.mkbl-sselect').val($(this).text())
		$('.mkbl-form-subfields fieldset.is-active').next().click()
		$('.mkbl-sselect').val('')
		if ($(this).closest('fieldset').is(':last-of-type'))
			console.log 'this is the last form field'
	
	$('.mkbl-select-option').on 'mouseover', ->
		$('.mkbl-select-option').removeClass('is-active')
		$(this).addClass('is-active')
 		
$ ->	
	Mkbl.slideInit()
	Mkbl.formInit()
	Mkbl.prepareField('field-name')

	$('.center').addClass('is-on')

	
