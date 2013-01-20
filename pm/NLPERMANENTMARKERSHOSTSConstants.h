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

#ifndef PMCONSTANTS_H
#define PMCONSTANTS_H

#define PM_AUTHENTICATION_RULE "nl.permanentmarkers.hosts"
#define PM_HOSTS_FILE_LOCATION "/private/etc/hosts"
#define PM_AUTHORISED_FILE "sys.openfile.readwrite./private/etc/hosts"
#define PM_AUTHENTICATION_RULE_COMMENT "Hosts.app /etc/hosts edit rule, will be reset if changed!"
#define PM_HOST_ENTRY_DATA_TYPE @"nl.permanentmarkers.NLPERMANENTMARKERSHOSTSHostEntry"
#define PMHOSTS_DEFAULTS_KEY @"NLPERMANENTMARKERSHOSTS_HOSTS_DEFAULTS_KEY"
#define PMHOSTS_DISABLE_ALL_KEY @"NLPERMANENTMARKERSHOSTS_HOSTS_DISABLE_ALL_KEY"
#endif