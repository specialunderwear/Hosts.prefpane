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

#ifndef HOSTS_H
#define HOSTS_H

// host entry
typedef struct {
    char * address;
    char * hostnames;
    char * comment;
} NLPERMANENTMARKERSHOSTS_CHostEntry;

NLPERMANENTMARKERSHOSTS_CHostEntry * NLPERMANENTMARKERSHOSTS_chostentry_create(char * address, char * hostnames, char * comment);
NLPERMANENTMARKERSHOSTS_CHostEntry * NLPERMANENTMARKERSHOSTS_chostentry_add_hostname(NLPERMANENTMARKERSHOSTS_CHostEntry *host_entry, char * hostname);
void NLPERMANENTMARKERSHOSTS_chostentry_destroy(NLPERMANENTMARKERSHOSTS_CHostEntry * host_entry);

// host entry parse errors
typedef struct {
    int linenumber;
    char * error;
    char * token;
} NLPERMANENTMARKERSHOSTS_CHostEntryError;

// validation
int NLPERMANENTMARKERSHOSTS_is_ip_address(const char * alledged_ip);
int NLPERMANENTMARKERSHOSTS_is_hostname(const char * alledged_hostname);

#endif
