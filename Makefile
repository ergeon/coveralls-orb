install: .install
.install: package.json
	npm install
	touch $@
coverage:
	npm run coverage
