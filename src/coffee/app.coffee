$ ->
	mySwiper = new Swiper '.swiper-container',
		direction: 'horizontal'
		loop: true
		pagination: '.swiper-pagination'
		nextButton: '.swiper-button-next'
		prevButton: '.swiper-button-prev'
		# scrollbar: '.swiper-scrollbar'
		centeredSlides: true
		slidesPerView: 3
		effect: 'coverflow'
		coverflow: {
			rotate: 0,
			stretch: 20,
			depth: 100,
			modifier: 1,
			slideShadows: false
		}
