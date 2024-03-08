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

##################################################
# Files
##################################################
autobak_src=$(app_name).sh
autobak=$(app_name)

all: run

##################################################
# run
##################################################
run: file?=$(autobak_src)
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
	find $(srcdir_top) -name '*~' -exec rm {} \;

##################################################
# distclean
##################################################
distclean: clean

# Develop
.PHONY: run
# Clean
.PHONY: clean
.PHONY: distclean
# Misc
.PHONY: all

