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

#ifndef HOSTS_C
#define HOSTS_C

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "hosts.h"
#include "hostsparser.tab.h"
#include "hostsscanner.h"

// host entry

NLPERMANENTMARKERSHOSTS_CHostEntry * NLPERMANENTMARKERSHOSTS_chostentry_create(char * address, char * hostnames, char * comment) {
    NLPERMANENTMARKERSHOSTS_CHostEntry * host_entry =  malloc(sizeof(NLPERMANENTMARKERSHOSTS_CHostEntry));
    host_entry->address = address;
    host_entry->hostnames = hostnames;
    host_entry->comment = comment;
    return host_entry;
}

NLPERMANENTMARKERSHOSTS_CHostEntry * NLPERMANENTMARKERSHOSTS_chostentry_add_hostname(NLPERMANENTMARKERSHOSTS_CHostEntry *host_entry, char * hostname) {
    if (host_entry->hostnames == NULL) {
        host_entry->hostnames = malloc((size_t) (strlen(hostname) + 1));
        strcpy(host_entry->hostnames, hostname);
    } else {
        int length = strlen(host_entry->hostnames) + strlen(hostname) + 2;
        char * hostnames = malloc((size_t) length);
        strcpy(hostnames, host_entry->hostnames);
        strcat(hostnames, " ");
        strcat(hostnames, hostname);
        free(host_entry->hostnames);
        host_entry->hostnames = hostnames;
    }
    return host_entry;
}

void NLPERMANENTMARKERSHOSTS_chostentry_destroy(NLPERMANENTMARKERSHOSTS_CHostEntry * host_entry) {
    if (host_entry->hostnames != NULL) 
        free(host_entry->hostnames);
    if (host_entry->address != NULL)
        free(host_entry->address);
    if (host_entry->comment != NULL)
        free(host_entry->comment);
    
    free(host_entry);
}

// validation

int NLPERMANENTMARKERSHOSTS_parsed_value_equals(const char * value, int target) {
    int result = 0;
    yyscan_t scanner;
    YYSTYPE NLPERMANENTMARKERSHOSTSlval;
    NLPERMANENTMARKERSHOSTSlex_init( &scanner );
    YY_BUFFER_STATE handle = NLPERMANENTMARKERSHOSTS_scan_string(value, scanner);
    if (NLPERMANENTMARKERSHOSTSlex(&NLPERMANENTMARKERSHOSTSlval, scanner) == target && strcmp(NLPERMANENTMARKERSHOSTSlval.string, value) == 0) {
        result = 1;
    }
    // if lex found a match and set the string it is on the heap.
    if (NLPERMANENTMARKERSHOSTSlval.string != NULL) {
        NLPERMANENTMARKERSHOSTSfree(NLPERMANENTMARKERSHOSTSlval.string, scanner);
    }
    NLPERMANENTMARKERSHOSTSlex_destroy(scanner);
    return result;    
}

int NLPERMANENTMARKERSHOSTS_is_ip_address(const char * alledged_ip) {
    return NLPERMANENTMARKERSHOSTS_parsed_value_equals(alledged_ip, ADDRESS);
}

int NLPERMANENTMARKERSHOSTS_is_hostname(const char * alledged_hostname) {
    return NLPERMANENTMARKERSHOSTS_parsed_value_equals(alledged_hostname, HOSTNAME);
}
#endif