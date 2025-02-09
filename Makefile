.PHONY: all

NAME=govee2telegraf
TAG=

HAS_CHANGES=$(shell git status -s 2>/dev/null | wc -l)
ifeq ($(HAS_CHANGES),0)
	TAG=$(shell git tag --points-at HEAD | sed -n 1p | sed 's/^v//g' | xargs)
endif

all:
	@echo
	@echo $(NAME):unstable
ifneq ($(TAG),)
	@echo $(NAME):latest
	@echo $(NAME):$(TAG)
endif
	@echo
	@cd lib/GoveeBTTempLogger && cmake -B ./build && cmake --build ./build
	@echo
	@mkdir -p dist/
#	docker builder prune --all
ifneq ($(TAG),)
	@docker build -t $(NAME):latest -t $(NAME):$(TAG) -f src/Dockerfile .
	@docker save $(NAME):$(TAG) | gzip > ./dist/$(NAME).$(TAG).tar.gz
	@echo "Saved to ./dist/$(NAME).$(TAG).tar.gz"
else
	@docker build -t $(NAME):unstable -f src/Dockerfile .
endif
