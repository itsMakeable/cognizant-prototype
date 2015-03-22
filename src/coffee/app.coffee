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
		
		$('#'+ currentField)
			.removeClass('is-active')
			.removeClass('is-typing')
			.addClass('is-filled')
			# console.log $(this)
		$('#enter-' + currentField)
			.addClass('is-hidden')
	Mkbl.setProgress()
	return !hasError

Mkbl.prepareField = (nextField) ->
	$('#enter-' + nextField)
		.removeClass('is-hidden')
	if $('#enter-' + nextField).find('.mkbl-select-bg').length
		# if !$('#enter-' + nextField).prev().find('.mkbl-select-bg').length
		if Mkbl.currentField != nextField
			setTimeout (->
				$('#enter-' + nextField).find('.mkbl-select-bg').addClass('is-open')
				$('.mkbl-form-hint.is-select').addClass('is-displayed')
				return
			), 1
		# else
		# 	if Mkbl.currentField != nextField
		# 		$('#enter-' + nextField).find('.mkbl-select-bg').addClass('is-open')
		# 		$('.mkbl-form-hint.is-select').addClass('is-displayed')

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
		$('.mkbl-button.is-active').prop('disabled', true)

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
			$('.mkbl-select-bg').removeClass('is-open')
			$('.mkbl-button').addClass('is-active').trigger('focus').prop('disabled', false)
			console.log 'this is the last form field'
			setTimeout (->
				success = Mkbl.saveField(thisField)
			), 400
			success = Mkbl.saveField(thisField)
			if (success) 
				$('.mkbl-button').addClass('is-active').trigger('focus').prop('disabled', false)

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
					$('.mkbl-select-bg').removeClass('is-open')
					$('.mkbl-button').addClass('is-active').trigger('focus').prop('disabled', false)
					
			else
				nextField = $('.mkbl-form-subfields fieldset.is-active').next().attr('id')
				Mkbl.moveToField nextField

	$(window).on 'keydown', (e) ->
		keyCode = e.keyCode or e.which
		if keyCode == 9 || keyCode == 13
			if $('.mkbl-form').find('.mkbl-select-bg.is-open .is-active').length
				e.preventDefault()
				console.log('option has been selected')
				# From Kyla: The following 3 lines are probably incorrect and should be deleted
				selectOption = $('.mkbl-select-bg.is-open .is-active').text()
				$('#enter-' + Mkbl.currentField + ' .mkbl-sselect').val(selectOption)

				nextField = $('.mkbl-form-subfields fieldset.is-active').next().attr('id')
				Mkbl.moveToField nextField

		if [40].indexOf(e.keyCode) > -1
			e.preventDefault()
			$('.mkbl-form-hint.is-select').removeClass('is-displayed')
			$('.mkbl-form-hint.is-input').addClass('is-displayed')
			selectActive = $('.mkbl-form').find('.mkbl-select-bg.is-open .is-active')
			selectActive.removeClass('is-active')
			if selectActive.next().is('.mkbl-select-option')
				selectActive.next().addClass('is-active')
			else
				$('.mkbl-select-bg.is-open .mkbl-select-option:first-of-type').addClass('is-active')

		if [38].indexOf(e.keyCode) > -1
			e.preventDefault()
			$('.mkbl-form-hint.is-select').removeClass('is-displayed')
			$('.mkbl-form-hint.is-input').addClass('is-displayed')
			selectActive = $('.mkbl-form').find('.mkbl-select-bg.is-open .is-active')
			selectActive.removeClass('is-active')
			if selectActive.prev().is('.mkbl-select-option')
				selectActive.prev().addClass('is-active')
			else
				$('.mkbl-select-bg.is-open .mkbl-select-option:last-of-type').addClass('is-active')


		

	$('.mkbl-select-option').on 'click', ->
		console.log('option has been clicked')
		$(this).parent().removeClass('is-open')
		selectOption = $(this).text()
		$('#enter-' + Mkbl.currentField + ' .mkbl-sselect').val(selectOption)

		if ($(this).closest('fieldset').is(':last-of-type'))
			$('.mkbl-select-bg').removeClass('is-open')
			$('.mkbl-form-hint.is-select').removeClass('is-displayed')
			$('.mkbl-form-hint.is-input').removeClass('is-displayed')
			setTimeout (->
				Mkbl.saveField Mkbl.currentField
				$('.mkbl-button').addClass('is-active').trigger('focus').prop('disabled', false)
			), 400
			
			console.log 'this is the last form field'

		else
			nextField = $('.mkbl-form-subfields fieldset.is-active').next().attr('id')
			Mkbl.moveToField nextField
	
	$('.mkbl-select-option').on 'mouseover', ->
		$('.mkbl-select-option').removeClass('is-active')
		$(this).addClass('is-active')
		$('#enter-' + Mkbl.currentField + ' .mkbl-main-input').val($(this).text())
		
$ ->	
	Mkbl.slideInit()
	Mkbl.formInit()
	Mkbl.prepareField('field-name')

	$('.center').addClass('is-on')

	
