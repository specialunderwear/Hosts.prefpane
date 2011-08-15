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
#import "pm/utils/NLPERMANENTMARKERSHOSTSFileWriter.h"
#import "pm/auth/NLPERMANENTMARKERSHOSTSAuthorization.h"
#import "pm/controllers/NLPERMANENTMARKERSHOSTSListController.h"

extern NSMutableArray * NLPERMANENTMARKERSHOSTShostsEntries;

@interface NLPERMANENTMARKERSHOSTSFileModel : NSObject {
@private
    NSUndoManager *undoManager;
    NLPERMANENTMARKERSHOSTSFileWriter *writer;
    NLPERMANENTMARKERSHOSTSAuthorization *authorization;
    IBOutlet NLPERMANENTMARKERSHOSTSListController *controller;
    BOOL needsLoad;
}

- (void) clear;
- (void) load;

- (NSUInteger) countOfHosts;
- (void) removeObjectFromHostsAtIndex:(NSUInteger) index;
- (id) objectInHostsAtIndex: (NSUInteger) index;
- (id) objectInHostsAtIndexes: (NSIndexSet *) range;
- (void)getHosts:(id *)aBuffer range:(NSRange)aRange;
- (void) insertObject:(id)object inHostsAtIndex:(NSUInteger) index;
- (NSMutableArray *) hosts;
- (void) setHosts:(NSMutableArray *)hosts;

@property (retain) NSUndoManager *undoManager;
//@property (assign) NSMutableArray *hosts;
@property (retain) NLPERMANENTMARKERSHOSTSAuthorization *authorization;
@end
