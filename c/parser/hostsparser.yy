%{
//    Hosts, a system preference pane to manage your hosts file.
//    Copyright (C) 2011  PermanentMarkers
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//    contact maintainer at hosts@permanentmarkers.nl

#include <stdio.h>
#include "hosts.h"
#include "hostsparser.tab.h"

#define yyterminate() return END
%}

%option nounput never-interactive yylineno reentrant noyywrap
%option prefix="NLPERMANENTMARKERSHOSTS"
%option bison-bridge

DIGIT    [0-9]
IPV4ADDRESS  (([[:digit:]]{1,3}"."){3}([[:digit:]]{1,3}))
HEX4         ([[:xdigit:]]{1,4})
HEXSEQ       ({HEX4}(:{HEX4})*)
HEXPART      ({HEXSEQ}|({HEXSEQ}::({HEXSEQ}?))|::{HEXSEQ})
ZONEID      (%[a-z0-9]+)
IPV6ADDRESS  ({HEXPART}(":"{IPV4ADDRESS})?)


%%

^{IPV6ADDRESS}{ZONEID}? {
        yylval->string = strdup(yytext);
        return ADDRESS;
    }

^{IPV4ADDRESS} {
        yylval->string = strdup(yytext);
        return ADDRESS;
    }

#[^\n]* {
        yylval->string = strdup(yytext);
        return COMMENT;
    }

[A-Za-z0-9]+[^\n#: \t]* {
        yylval->string = strdup(yytext);
        return HOSTNAME;
    }

[[:blank:]]   

"\n" return NEWLINE;


%%
