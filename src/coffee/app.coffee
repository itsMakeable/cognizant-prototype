Mkbl = {}

$.expr[':'].Contains = (a, i, m) ->
	(a.textContent or a.innerText or '').toUpperCase().indexOf(m[3].toUpperCase()) >= 0

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


Mkbl.listFilter = (input, list) ->
	$(input).on 'keyup', (e) ->
		keyCode = e.keyCode or e.which
		if keyCode != 9 && keyCode != 13 && keyCode != 38 && keyCode != 40
			filter = $(this).val()
			if filter && filter != ''
				console.log filter
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

Mkbl.currentField = null
Mkbl.timeout = null
Mkbl.saveField = (currentField) ->
	hasError = false
	currentFieldVal = $('#enter-' + currentField).find('.mkbl-main-input').val()
	if currentFieldVal == ''
		# || !$('#enter-' + currentField).hasClass('is-clean')
		hasError = true
		$('#enter-' + currentField).find('input').trigger('focus')
		$('#enter-' + currentField).find('input').addClass('has-error')
		$('.mkbl-form-progress-bar').addClass('has-error')
	else
		$('#' + currentField + ' .mkbl-subinput').html(currentFieldVal)
		$('#'+ currentField)
			.removeClass('is-active')
			.removeClass('is-typing')
			.addClass('is-filled')
		$('.mkbl-form-progress-bar')
			.removeClass('has-error')
		if $('#enter-' + currentField).find('.mkbl-select-bg').length
			# TODO: NEEDS TO CHECK IF THE VALUE IS EQUAL TO AN OPTION SELECT
			$('#enter-' + currentField).find('.mkbl-select-bg').removeClass('is-open')
			setTimeout (->
				$('#enter-' + currentField).addClass('is-hidden')
			), 400
		else
			$('#enter-' + currentField).addClass('is-hidden')
			

	Mkbl.setProgress()
	return !hasError

Mkbl.prepareField = (nextField) ->
	
	if $('#enter-' + nextField).find('.mkbl-select-bg').length
		
		if Mkbl.currentField != nextField
			setTimeout (->
				$('#enter-' + nextField).removeClass('is-hidden')
			), 400
			setTimeout (->
				$('#enter-' + nextField).find('.mkbl-select-bg').addClass('is-open').trigger('focus')
				$('.mkbl-form-hint.is-select').addClass('is-displayed')
				Mkbl.listFilter('.mkbl-sselect','.mkbl-select-bg.is-open')
				setTimeout (->
					$('#enter-' + nextField).find('.mkbl-main-input').trigger('focus')
				), 1
			), 450
	else
		$('#enter-' + nextField).removeClass('is-hidden')

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
		$('.mkbl-form-complete').removeClass('is-active')

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
		thisField = $(this).closest('fieldset').attr('id').substring(6)
		if ($(this).closest('fieldset').is(':last-of-type'))
			setTimeout (->
				success = Mkbl.saveField(thisField)
				if (success)
					$('.mkbl-select-bg').removeClass('is-open')
					$('.mkbl-form-hint.is-select').removeClass('is-displayed')
					$('.mkbl-form-hint.is-input').removeClass('is-displayed')
					$('.mkbl-button').addClass('is-active').trigger('focus').prop('disabled', false)
			), 400
		else
			$('.mkbl-form-subfields fieldset.is-active').next().click()

	$('.mkbl-main-input').on 'keydown', (e) ->
		thisField = $(this).closest('fieldset').attr('id').substring(6)
		if $(this).val() != ''
			$('.mkbl-form-hint.is-input').addClass('is-displayed')
			keyCode = e.keyCode or e.which
			# tab or enter	
			if keyCode == 9 || keyCode == 13
				e.preventDefault()
				$('.mkbl-select-bg').removeClass('is-open')
				if ($(this).closest('fieldset').is(':last-of-type'))
					setTimeout (->
						success = Mkbl.saveField(thisField)
					), 400
					if (success)
						$('.mkbl-button').addClass('is-active').trigger('focus').prop('disabled', false)
						
				else
					nextField = $('.mkbl-form-subfields fieldset.is-active').next().attr('id')
					Mkbl.moveToField nextField
			else
				$(this).removeClass('has-error')
				$('.mkbl-form-progress-bar').removeClass('has-error')

	$(window).on 'keydown', (e) ->
		keyCode = e.keyCode or e.which
		if keyCode == 9 || keyCode == 13
			e.preventDefault()
			if !$('.mkbl-form-subfields').find('.mkbl-fieldset.is-clean').length
				$('.mkbl-button').addClass('is-active').trigger('focus').prop('disabled', false)
				$('.mkbl-form-complete').addClass('is-active')
			else
				$('.mkbl-form-hint.is-select').removeClass('is-displayed')
				$('.mkbl-form-hint.is-input').removeClass('is-displayed')
				if $('.mkbl-form').find('.mkbl-select-bg.is-open').length

					if $('.mkbl-form').find('.mkbl-select-bg.is-open .is-active').length
						selectOption = $('.mkbl-select-bg.is-open .is-active').text()
						$('#enter-' + Mkbl.currentField + ' .mkbl-sselect').val(selectOption)
						nextField = $('.mkbl-form-subfields fieldset.is-active').next().attr('id')
						if $('#enter-' + Mkbl.currentField).is(':last-of-type')
							$('.mkbl-button').addClass('is-active').trigger('focus').prop('disabled', false)
						Mkbl.moveToField nextField
					else
						$('#enter-' + Mkbl.currentField).find('input').addClass('has-error')
						$('.mkbl-form-progress-bar').addClass('has-error')
						$('.mkbl-form-hint.is-select').addClass('is-displayed')
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
			$('#enter-' + Mkbl.currentField + ' .mkbl-main-input').val(selectActive.text())

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
			$('#enter-' + Mkbl.currentField + ' .mkbl-main-input').val(selectActive.text())


	$('.mkbl-select-option').on 'click', ->
		$(this).parent().removeClass('is-open')
		selectOption = $(this).text()
		$('#enter-' + Mkbl.currentField + ' .mkbl-sselect').val(selectOption)

		if ($(this).closest('fieldset').is(':last-of-type')) || !$('.mkbl-form-subfields').find('.mkbl-fieldset.is-clean').length
			$('.mkbl-select-bg').removeClass('is-open')
			$('.mkbl-form-hint.is-select').removeClass('is-displayed')
			$('.mkbl-form-hint.is-input').removeClass('is-displayed')
			$('.mkbl-button').addClass('is-active').trigger('focus').prop('disabled', false)
			setTimeout (->
				Mkbl.saveField Mkbl.currentField
				
			), 400
			$('.mkbl-form-complete').removeClass('is-active')
		else
			nextField = $('.mkbl-form-subfields fieldset.is-active').next().attr('id')
			Mkbl.moveToField nextField
	
	$('.mkbl-select-option').on 'mouseover', ->
		$('.mkbl-select-option').addClass('not-filtered').removeClass('is-active')
		$(this).addClass('is-active')
		$('#enter-' + Mkbl.currentField + ' .mkbl-main-input').val($(this).text())
		$('#enter-' + Mkbl.currentField).find('input').removeClass('has-error')
		$('.mkbl-form-progress-bar').removeClass('has-error')


$ ->	
	Mkbl.slideInit()
	Mkbl.formInit()
	Mkbl.prepareField('field-name')

	$('.center').addClass('is-on')

	
