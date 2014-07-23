# JAVA=/usr/lib/jvm/java-6-sun/bin/java
COFFEE=node_modules/.bin/coffee
MOCHA=node_modules/.bin/mocha
MOCHA_OPTS=--compilers coffee:coffee-script --globals document,window,Bling,$$,_ -R dot
TEST_FILES=tests/all.coffee tests/admin.coffee

SRC=$(wildcard src/*.coffee)
LIB=$(SRC:src/%.coffee=lib/%.js)

all: test build

build: $(LIB)

lib/%.js: src/%.coffee
	@mkdir -p $(@D)
	@$(COFFEE) -bcp $< > $@

test: tests/pass
	@echo "All tests are passing."

tests/pass: $(MOCHA) $(TEST_FILES) $(SRC) Makefile
	$(MOCHA) $(MOCHA_OPTS) $(TEST_FILES) && touch tests/pass

$(MOCHA):
	npm install mocha

$(COFFEE):
	npm install coffee-script

clean:
	rm  -f tests/pass
	rm -Rf $(LIB)

.PHONY: all clean test build
