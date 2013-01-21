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

#import <Cocoa/Cocoa.h>
#import "c/parser/hosts.h"

#define PM_HOST_ENTRY_ERROR_DOMAIN @"nl.permanentmarkers.PMHostsEntry.PM_HOST_ENTRY_ERROR_DOMAIN"
#define PM_HOST_ENTRY_INVALID_IP 1000
#define PM_HOST_ENTRY_INVALID_HOSTNAME 1001

@interface NLPERMANENTMARKERSHOSTSHostEntry : NSObject <NSCoding> {
	NSNumber * use;
	NSString * address;
	NSString * hostnames;
	NSString * comment;
    NSNumber * disabled;
}

- (id) initWithCHostEntry:(NLPERMANENTMARKERSHOSTS_CHostEntry *)host_entry;
- (void)addObserverForAll:(id)observer;
- (void)removeAllObservers:(id)observer;
- (NSString *)toString;
- (void)writeToFileHandle:(NSFileHandle *)handle;
- (void) pushUndoState:(NSDictionary *)change withManager:(NSUndoManager *)undoManager forKeyPath:(NSString *)keyPath;

@property(readwrite, copy) NSNumber *use;
@property(readwrite, copy) NSString *address;
@property(readwrite, copy) NSString *hostnames;
@property(readwrite, copy) NSNumber *disabled;
@property(readonly, copy) NSString *comment;

@end
