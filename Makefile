.PHONY: all publish

ifeq ($(shell command -v cmake 2>/dev/null),)
  $(error 'cmake' not found)
endif

ifeq ($(shell command -v docker 2>/dev/null),)
  $(error 'docker' not found)
endif

ifeq ($(shell command -v git 2>/dev/null),)
  $(error 'git' not found)
endif

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

publish: all
ifneq ($(TAG),)
	echo
	docker tag $(NAME):$(TAG) medo64/$(NAME):$(TAG)
	docker push medo64/$(NAME):$(TAG)
	echo
	docker tag $(NAME):latest medo64/$(NAME):latest
	docker push medo64/$(NAME):latest
endif
	echo
	docker tag $(NAME):unstable medo64/$(NAME):unstable
	docker push medo64/$(NAME):unstable
