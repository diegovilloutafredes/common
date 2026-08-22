.PHONY: generate build_xcframework patch minor major ci

generate:
	xcodegen generate

# Local mirror of the (temporarily disabled) GitHub Actions test job.
ci:
	./scripts/ci_local.sh

build_xcframework: generate
	./build_xcframework.sh

patch:
	./release.sh patch

minor:
	./release.sh minor

major:
	./release.sh major