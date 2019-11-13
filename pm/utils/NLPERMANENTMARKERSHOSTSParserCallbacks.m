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

#import <Foundation/Foundation.h>
#import "pm/utils/NLPERMANENTMARKERSHOSTSParserCallbacks.h"
#import "pm/models/NLPERMANENTMARKERSHOSTSHostEntry.h"

// defined in NLPERMANENTMARKERSHOSTSFileModel.m
extern NSMutableArray * NLPERMANENTMARKERSHOSTShostsEntries;

// callback for the hosts file parser.
void NLPERMANENTMARKERSHOSTSonHostEntryFound(NLPERMANENTMARKERSHOSTS_CHostEntry * entry) {
	NLPERMANENTMARKERSHOSTSHostEntry * host_entry = [[NLPERMANENTMARKERSHOSTSHostEntry alloc] initWithCHostEntry:entry];
	[NLPERMANENTMARKERSHOSTShostsEntries addObject:host_entry];
	[host_entry release];
	NLPERMANENTMARKERSHOSTS_chostentry_destroy(entry);
}

// error handler for the hosts file parser
void NLPERMANENTMARKERSHOSTSonHostsParseError(NLPERMANENTMARKERSHOSTS_CHostEntryError * error) {
    NSString *windowTitle = NSLocalizedStringFromTable(@"Parse error", @"HostsAppDelegate",
                                                       @"error: title");
    NSString *errorFormatString = NSLocalizedStringFromTable(@"In /private/etc/hosts on line:%i %s\n\n%s\n\nShould this line be permanently removed from /private/etc/hosts?\nChoose no to quit Hosts and manually correct the error.",@"HostsAppDelegate",
                                                             @"error: description");
    NSString *errorString = [NSString stringWithFormat:errorFormatString, error->linenumber, error->token, error->error];
    
    NSInteger choice = NSRunAlertPanel(windowTitle, @"%@", errorString, @"No", nil, @"Yes");
    if (choice == NSAlertDefaultReturn) {
        [[NSApplication sharedApplication] terminate:nil];
    }
}
