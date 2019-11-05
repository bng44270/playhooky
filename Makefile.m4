TARGETS := BUILTFILES

INSTBIN := INSTALLEDFILES

define getsetting
$$(grep "^$(2)[ \t]*" $(1) | sed 's/^$(2)[ \t]*//g')
endef

all: $(TARGETS)

$(TARGETS):
	mkdir -p build
	m4 -DBASEDIR="$(call getsetting,tmp/settings.txt,BASEDIR)" -DKEYTEXT="$(call getsetting,tmp/settings.txt,KEYTEXT)" checks/$$(basename $@).m4 > $@
	chmod +x $@

clean:
	rm -rf tmp
	rm -rf build

install: $(INSTBIN)

$(INSTBIN): 
	mkdir -p $(call getsetting,tmp/settings.txt,BASEDIR)
	mkdir -p $(call getsetting,tmp/settings.txt,BASEDIR)/bin
	mkdir -p $(call getsetting,tmp/settings.txt,BASEDIR)/conf
	cp build/$$(basename $@) $@
	$@ cache 
