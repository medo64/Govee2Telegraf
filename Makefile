.PHONY: all

NAME=govee2telegraf
TAG=latest
VERSION=$(shell git tag --points-at HEAD | sed -n 1p | sed 's/^v//g' | xargs)
HAS_CHANGES=$(shell git status -s 2>/dev/null | wc -l)

all:
	@echo
	@echo $(NAME):$(TAG)
	@echo
	@cd lib/GoveeBTTempLogger && cmake -B ./build && cmake --build ./build
	@echo
	@mkdir -p dist/
#	docker builder prune --all
	@if [ $(HAS_CHANGES) -eq 0 ] && [ "$(VERSION)" != "" ]; then \
		docker build -t $(NAME):$(TAG) -t $(NAME):$(VERSION) -f src/Dockerfile . \
	; else \
		docker build -t $(NAME):$(TAG) -f src/Dockerfile . \
	; fi
	@docker save $(NAME):$(TAG) | gzip > dist/$(NAME).$(TAG).tar.gz
