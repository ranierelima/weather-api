SOURCE_FOLDERS?=$$(go list ./... | grep -v /vendor/)
TEST_PATTERN?=.
TEST_OPTIONS?=-race -covermode=atomic -coverprofile=coverage.txt

setup: ## Install all the build and lint dependencies
	go get -u gopkg.in/alecthomas/gometalinter.v2
	go get -u github.com/golang/dep/cmd/dep
	go get -u golang.org/x/tools/cmd/cover
	go get -u golang.org/x/tools/cmd/goimports
	dep ensure
	gometalinter --install --update

test: ## Run all the tests
	gotestcover $(TEST_OPTIONS)  $(SOURCE_FOLDERS) -run $(TEST_PATTERN) -timeout=1m

cover: test ## Run all the tests and opens the coverage report
	go tool cover -html=coverage.txt

fmt: ## gofmt and goimports all go files
	find . -name '*.go' -not -wholename './vendor/*' | while read -r file; do gofmt -w -s "$$file"; goimports -w "$$file"; done

lint: ## Run all the linters
	gometalinter --vendor --disable-all \
		--enable=deadcode \
		--enable=ineffassign \
		--enable=gosimple \
		--enable=staticcheck \
		--enable=gofmt \
		--enable=goimports \
		--enable=dupl \
		--enable=misspell \
		--enable=errcheck \
		--enable=vet \
		--enable=vetshadow \
		--deadline=10m \
		./...

ci: lint test ## Run all the tests and code checks

build: ## Build a beta version
	go build -race -o ./dist/logreplay ./main.go

install: ## Install to $GOPATH/src
	go install ./...

run-local: ## Build a beta version
	go build -o weather-api
	./weather-api

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help