Mkbl = {}

Mkbl.slideInit = (el) ->
	Mkbl.slider = el
	Mkbl.numberOfSlides = Mkbl.slider.find('.mkbl-slide').length
	Mkbl.activeSlide = 0
	Mkbl.setActiveSlide Mkbl.activeSlide

Mkbl.setActiveSlide = (s) ->
	$('.mkbl-slide')
		.removeClass('slide-before-2')
		.removeClass('slide-before-1')
		.removeClass('slide-active')
		.removeClass('slide-after-1')
		.removeClass('slide-after-2')
		.css('background-image', 'none')

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

Mkbl.formInit = ->
	Mkbl.mainInput = $('.mkbl-main-input')
	Mkbl.progressDenominator = $('.mkbl-form-subfields .mkbl-fieldset').length

	currentField = null

	$('.mkbl-form-subfields .mkbl-fieldset').on 'click', ->
		nextField = $(this).attr('id')
		hasError = false

		# $(this).addClass('is-active')

		if currentField == nextField
			return

		currentFieldVal = $('#enter-' + currentField).find('.mkbl-main-input').val()

		checkInputValue = ->
			if currentFieldVal == ''
				hasError = true
				$('#enter-' + currentField).find('input').trigger('focus')
				$('#enter-' + currentField).find('input')
					.addClass('has-error')
				#$('#'+ currentField)
				#	.removeClass('is-typing')
				#	.removeClass('is-active')
				Mkbl.setProgress()
			else
				$('#' + currentField + ' .mkbl-subinput')
					.html(currentFieldVal)
				$('#enter-' + currentField)
					.addClass('is-hidden')
				$('#'+ currentField)
					.removeClass('is-active')
					.addClass('is-filled')

		setInputValue = ->
			$('#enter-' + nextField)
				.removeClass('is-hidden')
			
			$('#' + nextField)
				.addClass('is-active')
				.removeClass('is-clean')
			$('#enter-' + nextField)
				.find('.mkbl-main-input')
				.trigger('focus')
			Mkbl.setProgress()

		keypressTimeout = null
		
		$('#enter-' + nextField).find('.mkbl-main-input').on 'keydown', ->
			deanimateEllipse = ->
				$('#' + nextField).removeClass('is-typing')
			
			$('#' + nextField).addClass('is-typing')

			if timeout
				clearTimeout timeout
				timeout = null
				animateEllipse
			timeout = setTimeout(deanimateEllipse, 1500)

		if currentField != null
			switch currentField
				when 'field-name'
					checkInputValue()
				when 'field-email'
					checkInputValue()
				when 'field-org'
					checkInputValue()
				when 'field-phone'
					checkInputValue()
				when 'field-region'
					checkInputValue()
				when 'field-inquiry'
					checkInputValue()
		if !hasError
			# $(this).addClass('is-active')
			switch nextField
				when 'field-name'
					setInputValue()
				when 'field-email'
					setInputValue()
				when 'field-org'
					setInputValue()
				when 'field-phone'
					setInputValue()
				when 'field-region'
					setInputValue()
				when 'field-inquiry'
					setInputValue()
			currentField = nextField

		$('.mkbl-main-input').one 'keypress', ->
			if $('.mkbl-main-input').is('input')
				$('.mkbl-form-hint.is-input').addClass('is-displayed')
		$('.mkbl-select').on 'focus', ->
			$('.mkbl-form-hint.is-select').addClass('is-displayed')
		$('.mkbl-main-input').on 'blur', ->
			$('.mkbl-form-hint').removeClass('is-displayed')

	Mkbl.mainInput.on 'keydown', (e) ->
		
		keyCode = e.keyCode or e.which
		# tab
		if keyCode == 9 || keyCode == 13
			# console.log e.keyCode
			e.preventDefault()
			if ($(this).closest('fieldset').attr('id') == 'enter-field-inquiry')
				# checkInputValue()
				$('.mkbl-button').trigger('focus')
			else
				$('.mkbl-form-subfields fieldset.is-active').next().click()


 		
Mkbl.setProgress = ->
	progressDividend = $('.mkbl-form-subfields .mkbl-fieldset.is-filled').length
	$('.mkbl-form-progress-bar-progress').css('width', ((progressDividend/Mkbl.progressDenominator) * 100) + '%')


$ ->	
	Mkbl.slideInit $('.mkbl-slide-container')
	Mkbl.formInit()
	$('#field-name').click()
	$('#js-next-arrow').on 'click', ->
		Mkbl.nextSlide()

	$('.mkbl-slide-container').on 'click', '.slide-after-1', ->
		Mkbl.nextSlide()

	$('#js-prev-arrow').on 'click', ->
		Mkbl.prevSlide()
	$('.mkbl-slide-container').on 'click', '.slide-before-1', ->
		Mkbl.prevSlide()

	$('.js-form-next').on 'click', ->
		Mkbl.nextInput()

	$('.center').addClass('is-on')
