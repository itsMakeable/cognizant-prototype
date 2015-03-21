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
	if currentFieldVal == '' || !$('#enter-' + currentField).hasClass('is-clean')
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
			.addClass('is-filled')
	return !hasError

Mkbl.prepareField = (nextField) ->
	$('#enter-' + nextField)
		.removeClass('is-hidden')
		.find('.mkbl-select-bg')
		.addClass('is-open')
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

		deanimateEllipse = ->
			$('#' + thisField).removeClass('is-typing')
		animateEllipse = ->
			$('#' + thisField).addClass('is-typing')

		animateEllipse()
		if Mkbl.timeout
			clearTimeout Mkbl.timeout
			Mkbl.timeout = null
		Mkbl.timeout = setTimeout(deanimateEllipse, 1500)

	$('.mkbl-sselect').on 'focus', ->
		$('.mkbl-form-hint.is-input').removeClass('is-displayed')
		$('.mkbl-form-hint.is-select').addClass('is-displayed')
	
	$('.mkbl-main-input').on 'blur', ->
		$('.mkbl-form-hint').removeClass('is-displayed')

	$('.js-form-next').on 'click', (e) ->
		if ($(this).closest('fieldset').is(':last-of-type'))
			# checkInputValue()
			$('.mkbl-button').trigger('focus')
		else
			$('.mkbl-form-subfields fieldset.is-active').next().click()

	$('.mkbl-main-input').on 'keydown', (e) ->
		thisField = $(this).closest('fieldset').attr('id').substring(6)
		if !$(this).hasClass('.mkbl-sselect')
			$('.mkbl-form-hint.is-input').addClass('is-displayed')
		keyCode = e.keyCode or e.which
		# tab
		if keyCode == 9 || keyCode == 13
			e.preventDefault()
			if $(this).is('.mkbl-sselect')
				selectOption = $('.mkbl-select-bg.is-open .is-active').text()
				Mkbl.mainInput.val(selectOption)
				$('.mkbl-form-subfields fieldset.is-active').next().click()
				$(this).next('.mkbl-select-bg').removeClass('is-open')
				$('.mkbl-sselect').val('')
			else
				if ($(this).closest('fieldset').is(':last-of-type'))
					success = Mkbl.saveField(thisField)
					if (success) 
						$('.mkbl-button').trigger('focus')
				else
					nextField = $('.mkbl-form-subfields fieldset.is-active').next().attr('id')
					Mkbl.moveToField nextField
		# Down
		else if keyCode == 40
			e.preventDefault()
			$('.mkbl-form-hint.is-select').removeClass('is-displayed')
			selectActive = $('.mkbl-form').find('.mkbl-select-bg.is-open .is-active')
			selectActive.removeClass('is-active')
			selectActive.next().addClass('is-active')

		# Up
		else if keyCode == 38
			e.preventDefault()
			$('.mkbl-form-hint.is-select').removeClass('is-displayed')
			selectActive = $('.mkbl-form').find('.mkbl-select-bg.is-open .is-active')
			selectActive.removeClass('is-active')
			selectActive.prev().addClass('is-active')

	$('.mkbl-main-input').on 'focus', (e) ->
		if $(this).hasClass('.mkbl-sselect')
			$('.mkbl-form-hint.is-select').removeClass('is-displayed')
			$('.mkbl-form-hint.is-input').addClass('is-displayed')

	$('.mkbl-select-option').on 'mouseover', ->
		$('.mkbl-select-option').removeClass('is-active')
		$(this).addClass('is-active')

	$('.mkbl-select-option').on 'click', ->
		$('.mkbl-sselect').val($(this).text())
		$('.mkbl-form-subfields fieldset.is-active').next().click()
		$(this).closest('.mkbl-select-bg').removeClass('is-open')
		$('.mkbl-sselect').val('')
	
	
 		
$ ->	
	Mkbl.slideInit()
	Mkbl.formInit()
	Mkbl.prepareField('field-name')

	$('.center').addClass('is-on')

	
