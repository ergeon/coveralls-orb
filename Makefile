PATH_TO_TESTS = sample_test.py

install: .install
.install: package.json
	npm install
	touch $@

node-coverage:
	npm run coverage

python-coverage-test:
	coverage run $(PATH_TO_TESTS)
	
coverage-report:
	coverage report

python-coverage:python-coverage-test coverage-report

clean:
	rm -rf .install coverage

.PHONY: install node-coverage python-coverage-test coverage-report coverage clean
