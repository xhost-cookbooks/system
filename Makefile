.PHONY: docker-build docker-tag docker-push

release:: docker-build docker-tag docker-push

docker-push::
	@docker push flaccid/chef-system

docker-tag::
	@docker tag -f chef-system flaccid/chef-system

docker-build::
	@berks package && docker build -t chef-system .
