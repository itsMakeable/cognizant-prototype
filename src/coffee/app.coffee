Mkbl = {}

Mkbl.init = (el) ->
	Mkbl.slider = el
	Mkbl.numberOfSlides = Mkbl.slider.find('.mkbl-slide').length
	Mkbl.activeSlide = 0
	Mkbl.setActiveSlide Mkbl.activeSlide

Mkbl.setActiveSlide = (s) ->
	$('.mkbl-slide').removeClass('slide-before-2').removeClass('slide-before-1').removeClass('slide-active').removeClass('slide-after-1').removeClass('slide-after-2').css('background-image', 'none');
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
	Mkbl.activeSlide = (Mkbl.activeSlide + 1) % Mkbl.numberOfSlides
	Mkbl.setActiveSlide Mkbl.activeSlide

Mkbl.prevSlide = ->
	Mkbl.activeSlide = (Mkbl.activeSlide - 1 + Mkbl.numberOfSlides) % Mkbl.numberOfSlides
	Mkbl.setActiveSlide Mkbl.activeSlide

	
Mkbl.init $('.mkbl-slide-container')


$('#js-next-arrow').on 'click', ->
	Mkbl.nextSlide()

$('#js-prev-arrow').on 'click', ->
	Mkbl.prevSlide()