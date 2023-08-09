PATH_TO_TESTS = sample_test.py

npm-install: .install
.install: package.json
	npm install
	touch $@

pip-install: .pip-install
.pip-install:
	pip install coveralls

node-coverage:
	npm run coverage

python-coverage-test:
	coverage run $(PATH_TO_TESTS)
	
coverage-report:
	coverage report

python-coverage:python-coverage-test coverage-report

clean:
	rm -rf .install coverage

.PHONY: npm-install python-install node-coverage python-coverage-test coverage-report coverage clean
