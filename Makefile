# JAVA=/usr/lib/jvm/java-6-sun/bin/java
COFFEE=node_modules/.bin/coffee
MOCHA=node_modules/.bin/mocha
MOCHA_OPTS=--compilers coffee:coffee-script --globals document,window,Bling,$$,_ -R dot
TEST_FILES=tests/all.coffee tests/admin.coffee

all: test

test: tests/pass
	@echo "All tests are passing."

tests/pass: $(MOCHA) $(TEST_FILES)
	$(MOCHA) $(MOCHA_OPTS) $(TEST_FILES) && touch tests/pass

$(MOCHA):
	npm install mocha

$(COFFEE):
	npm install coffee-script

clean:
	rm -f tests/pass

.PHONY: all clean test
