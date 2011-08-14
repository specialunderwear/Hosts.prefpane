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
#include <stdlib.h>
#include <string.h>
#include "hosts.h"

void print_chost_entry(NLPERMANENTMARKERSHOSTS_CHostEntry * entry) {
    printf("CHostentry by print_chost_entry callback:  %s\t%s\t%s\n", entry->address, entry->hostnames, entry->comment);
    NLPERMANENTMARKERSHOSTS_chostentry_destroy(entry);
}

int main(void){
    NLPERMANENTMARKERSHOSTS_CHostEntry * a = NLPERMANENTMARKERSHOSTS_chostentry_create(NULL, NULL, NULL);
    NLPERMANENTMARKERSHOSTS_chostentry_add_hostname(a, "lamo");
    printf("woot %s", a->hostnames);
    NLPERMANENTMARKERSHOSTS_chostentry_add_hostname(a, " more!!");
    printf("woot %s\n", a->hostnames);
    NLPERMANENTMARKERSHOSTS_chostentry_destroy(a);
    NLPERMANENTMARKERSHOSTSparsefile("/etc/hosts", print_chost_entry, NULL);
    printf("Het is een ip %d\n", NLPERMANENTMARKERSHOSTS_is_ip_address("127.0.0.1"));
    printf("Het is geen ip %d\n", NLPERMANENTMARKERSHOSTS_is_ip_address("127.0.0.1kaka"));
    printf("Het is geen ip %d\n", NLPERMANENTMARKERSHOSTS_is_ip_address("ben je sukkel"));
    return 0;
}