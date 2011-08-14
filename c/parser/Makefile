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

all: libs
	gcc -o hosts -g main.c hostsparser.o

libs:
	/opt/local/bin/bison -d hostsparser.y
	flex --header-file=hostsscanner.h hostsparser.yy
	/opt/local/bin/bison --report=state hostsparser.y
	cc -c -g --combine hosts.c lex.NLPERMANENTMARKERSHOSTS.c hostsparser.tab.c -o hostsparser.o

release: clean libs
	gcc -O3 -o hosts main.c hostsparser.o
	strip hosts

clean:
	-rm -f *.exe *.o hostsparser.tab.c 1 *~ hosts hostsscanner.h hostsparser.output hostsparser.tab.h lex.*.c
	-rm -fr hosts.dSYM