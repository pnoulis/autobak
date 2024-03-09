#!/usr/bin/make

SHELL:=/usr/bin/bash
.DEFAULT_GOAL:=run
.SECONDEXPANSION:
.ONESHELL:
.EXPORT_ALL_VARIABLES:

##################################################
# Application
##################################################
app_name=autobak
app_version=0.0.1
app_distname=$(app_name)-v$(app_version)

##################################################
# Directories
##################################################
srcdir_top=.
srcdir=$(srcdir_top)/src
buildir=$(srcdir_top)/build
bindir=~/bin

##################################################
# Files
##################################################
in_autobak=$(app_name).sh
out_autobak=$(app_name)

all: build

##################################################
# Build
##################################################
build: $(out_autobak)

$(out_autobak): $(in_autobak)
	cat $^ > $@
	chmod +x $@

##################################################
# Install
##################################################
install: $(out_autobak)
	cp --update $(out_autobak) $(bindir)

##################################################
# run
##################################################
run: file?=$(in_autobak)
run: $(file)
	@if [[ "$${file:-}" == "" ]]; then
	echo "Usage: 'make run file [args]'"
	exit 1
	fi
	$(loadenv)
	extension="$${file##*.}"
	case $$extension in
	sh)
	$(SHELL) $(file) $(args)
	;;
	js | mjs)
	$(node) $(nodeflags) $(file) $(args)
	;;
	ts)
	$(tsnode) $(nodeflags) $(file) $(args)
	;;
	*)
	echo "Unrecognized extension: $$extension"
	echo "Failed to 'make $@ $^'"
	;;
	esac

.DEFAULT:
	@if [ ! -f "$<" ]; then
	echo "Missing file $${file:-}"
	exit 1
	fi


##################################################
# clean
##################################################
clean:
	-rm -f *.log
	-rm -f .#*
	-rm -f env.*
	-rm -f $(out_autobak)
	find $(srcdir_top) -name '*~' -exec rm {} \;

##################################################
# distclean
##################################################
distclean: clean

# Develop
.PHONY: run
.PHONY: build
# Distribute
.PHONY: install
# Clean
.PHONY: clean
.PHONY: distclean
# Misc
.PHONY: all

