image:
	docker build -t chefbe/lego-tec .

image.push: image
	@docker push chefbe/lego-tec
