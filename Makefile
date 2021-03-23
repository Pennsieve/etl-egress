.PHONY: help build test venv devvenv clean

PIP_PACKAGES := boto3 stringcase
PIP_DEV_PACKAGES := pylint pytest pytest-cov
WORKING_DIR := $(shell pwd)
LAMBDA_BUCKET ?= pennsieve-cc-lambda-functions-use1
FUNCTION_NAME := $(shell basename ${WORKING_DIR})
PACKAGE_NAME := ${FUNCTION_NAME}-${VERSION}.zip

.DEFAULT: help
help:
	@echo "Make Help"
	@echo "make test - make virtual env and run tests"
	@echo "make build - make virtualenv, make and build lambda"
	@echo "make venv - setup virtualenv"
	@echo "make clean - remove *.pyc files"

build:
ifndef VERSION
	${error VERSION is not set}
endif
	make venv

	cd ${WORKING_DIR}/egress/ && \
	zip -r9 ${WORKING_DIR}/${PACKAGE_NAME} *

	cd ${WORKING_DIR}/venv/lib/python2.7/site-packages/ && \
	zip -r9 ${WORKING_DIR}/${PACKAGE_NAME} *

	aws s3 cp ${WORKING_DIR}/${PACKAGE_NAME} s3://${LAMBDA_BUCKET}/${FUNCTION_NAME}/${PACKAGE_NAME}
	rm -rf ${WORKING_DIR}/${PACKAGE_NAME}
	#devvenv

test: devvenv
	devvenv/bin/python -m py.test --cov=egress

lint: devvenv
	python -m pylint --disable=line-too-long egress/

devvenv: requirements-dev.txt
	make clean
	test -d devvenv || virtualenv devvenv
	devvenv/bin/pip install -U ${PIP_PACKAGES} ${PIP_DEV_PACKAGES}
	devvenv/bin/pip freeze --local > ./requirements-dev.txt
	touch devvenv/bin/activate

venv: requirements.txt
	make clean
	test -d venv || virtualenv venv
	venv/bin/pip install -U ${PIP_PACKAGES}
	venv/bin/pip freeze --local > ./requirements.txt
	touch venv/bin/activate

clean:
	find . -name '*.pyc' -exec rm -f {} +
	rm -rf tests/__pycache__
