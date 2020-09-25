#    Hosts, a system preference pane to manage your hosts file.
#    Copyright (C) 2011  PermanentMarkers
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    contact maintainer at hosts@permanentmarkers.nl
ifndef BISON_PATH
	BISON_PATH := $(shell which bison)
endif
BISON_VERSION_GT_2_5 = $(shell $(BISON_PATH) --version | head -n1 | cut -d' '  -f4 | cut -c 3 | xargs echo "2.5 <= " | bc)



.PHONY:
ifneq ($(BISON_VERSION_GT_2_5), 1)
	@echo `$(BISON_PATH) --version | head -n1`
	@echo "bison version must be greater then 2.5, make sure bison 2.5 is on your PATH or BISON_PATH is set to the correct bison in the parser's build settings."
	@false
endif

all: .PHONY libs
	gcc -Wno-implicit-function-declaration -o hosts -g main.c hostsparser.o

libs: .PHONY
	$(BISON_PATH) -d hostsparser.y
	flex --header-file=hostsscanner.h hostsparser.yy
	$(BISON_PATH) --report=state hostsparser.y
	cc -Wno-implicit-function-declaration -c -g hosts.c lex.NLPERMANENTMARKERSHOSTS.c hostsparser.tab.c
	ld -r hosts.o lex.NLPERMANENTMARKERSHOSTS.o hostsparser.tab.o -o hostsparser.o
release: clean libs
	gcc -Wno-implicit-function-declaration -O3 -o hosts main.c hostsparser.o
	strip hosts

clean:
	-rm -f *.exe *.o hostsparser.tab.c 1 *~ hosts hostsscanner.h hostsparser.output hostsparser.tab.h lex.*.c
	-rm -fr hosts.dSYM
	
install:

