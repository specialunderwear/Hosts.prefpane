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

    #include <string.h>
    #include <stdlib.h>
    #include <stdio.h>
    #include "hosts.h"
    #include "hostsparser.h"
    
    #ifndef YYSTYPE 
    #define YYSTYPE NLPERMANENTMARKERSHOSTS_YYSTYPE
    #define YYSTYPE_IS_TRIVIAL 1
    #define yystype YYSTYPE
    #define YYSTYPE_IS_DECLARED 1
    typedef union YYSTYPE
    {
        NLPERMANENTMARKERSHOSTS_CHostEntry * hostentry;
        char * string;
    } YYSTYPE;
    #endif

    // predeclare bison functions
    void NLPERMANENTMARKERSHOSTSerror (void * scanner, char const * error);
    
    // predeclare lex functions.
    FILE *NLPERMANENTMARKERSHOSTSget_in  (void * scanner);
    void NLPERMANENTMARKERSHOSTSset_in (FILE *  in_str , void * scanner);
    YYSTYPE * NLPERMANENTMARKERSHOSTSget_lval (void * scanner );

    // callback for parser results.
    void (*NLPERMANENTMARKERSHOSTS_callback)(NLPERMANENTMARKERSHOSTS_CHostEntry *) = NULL;
    // callback for parser errors.
    void (*NLPERMANENTMARKERSHOSTS_error_callback)(NLPERMANENTMARKERSHOSTS_CHostEntryError *) = NULL;
    
    void NLPERMANENTMARKERSHOSTSparsefile(char * filename, void (*callback)(NLPERMANENTMARKERSHOSTS_CHostEntry *), void (*error_handler)(NLPERMANENTMARKERSHOSTS_CHostEntryError *) ) {
        void * scanner;
        NLPERMANENTMARKERSHOSTS_callback = callback;
        NLPERMANENTMARKERSHOSTS_error_callback = error_handler;
        
        NLPERMANENTMARKERSHOSTSlex_init (&scanner);
        FILE *file_handle = fopen(filename, "r");
        NLPERMANENTMARKERSHOSTSset_in(file_handle, scanner);
        NLPERMANENTMARKERSHOSTSparse(scanner);
        NLPERMANENTMARKERSHOSTSlex_destroy(scanner);
    }
%}

%define api.pure
%error-verbose
%name-prefix="NLPERMANENTMARKERSHOSTS"

%expect 2
%token COMMENT ADDRESS HOSTNAME NEWLINE
%token END 0

%union {
    NLPERMANENTMARKERSHOSTS_CHostEntry * hostentry;
    char * string;
}

%type <string> ADDRESS COMMENT HOSTNAME
%type <hostentry> hostnames
%type <hostentry> rule

%destructor { free($$); } ADDRESS COMMENT HOSTNAME
%destructor { NLPERMANENTMARKERSHOSTS_chostentry_destroy($$);} hostnames rule

%parse-param {void *scanner}
%lex-param {yyscan_t *scanner}

%%

    input:
    | input line
;

hostnames: HOSTNAME { $$ = NLPERMANENTMARKERSHOSTS_chostentry_create(NULL, $1, NULL); }
    | hostnames HOSTNAME { $$ = NLPERMANENTMARKERSHOSTS_chostentry_add_hostname($1, $2); }
;

line: rule NEWLINE { NLPERMANENTMARKERSHOSTS_callback($1); }
    | rule { NLPERMANENTMARKERSHOSTS_callback($1);}
    | NEWLINE { NLPERMANENTMARKERSHOSTS_callback(NLPERMANENTMARKERSHOSTS_chostentry_create(NULL, NULL, NULL)); }
    | error NEWLINE {yyerrok;}
;

rule: ADDRESS hostnames COMMENT { $2->address = $1; $2->comment = $3; $$ = $2;}
    | ADDRESS hostnames { $2->address = $1; $$ = $2;}
    | COMMENT { $$ = NLPERMANENTMARKERSHOSTS_chostentry_create(NULL, NULL, $1);}
;

%%

void NLPERMANENTMARKERSHOSTSerror (void * scanner, char const * error) {
    YYSTYPE * lval = NLPERMANENTMARKERSHOSTSget_lval(scanner);

    if (NLPERMANENTMARKERSHOSTS_error_callback != NULL) {
        NLPERMANENTMARKERSHOSTS_CHostEntryError error_obj;
        
        error_obj.linenumber = NLPERMANENTMARKERSHOSTSget_lineno(scanner);
        error_obj.error = strdup(error);
        error_obj.token = strdup(lval->string);
        
        NLPERMANENTMARKERSHOSTS_error_callback(&error_obj);
        
        free(error_obj.error);
        free(error_obj.token);

    } else {
        printf("Error parsing /etc/hosts line:%i %s\n%s\n", NLPERMANENTMARKERSHOSTSget_lineno(scanner), lval->string, error);
    }
}
