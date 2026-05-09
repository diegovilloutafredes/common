.PHONY: generate build_xcframework patch minor major

generate:
	xcodegen generate

build_xcframework: generate
	./build_xcframework.sh

patch:
	./release.sh patch

minor:
	./release.sh minor

major:
	./release.sh major