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

#ifndef HOSTSPARSER_H
#define HOSTSPARSER_H

# include "hosts.h"

/**
 * Set the callback that will be called each time a line from the /etc/hosts file
 * was parsed.
 * 
 * @param callback the function that will be called after a line was parsed. It
 * should accept a HostEntry * as a parameter.
 */
void NLPERMANENTMARKERSHOSTSset_callback(void (*callback)(NLPERMANENTMARKERSHOSTS_CHostEntry *));

/**
 * Set the error handler that will be called when an error occurs during parsing.
 * 
 * @param error_handler the function that will be called when an error occurred. It
 * should accept a NLPERMANENTMARKERSHOSTS_CHostEntryError * as a parameter.
 */
void NLPERMANENTMARKERSHOSTSset_error_callback(void (*error_handler)(NLPERMANENTMARKERSHOSTS_CHostEntryError *));

/**
 * Parse a hosts file.
 * http://publib.boulder.ibm.com/infocenter/zvm/v5r3/index.jsp?topic=/com.ibm.zvm.v53.kill0/hcsk5b2021.htm
 *
 * @param file_name the name and path to the hosts file.
 * @param callback this function will be called each time a hostentry is parsed.
 * @param error_handler this function will be called each time a parse error occurred.
 */
void NLPERMANENTMARKERSHOSTSparsefile(char * filename, void (*callback)(NLPERMANENTMARKERSHOSTS_CHostEntry *), void (*error_handler)(NLPERMANENTMARKERSHOSTS_CHostEntryError *) );

#endif