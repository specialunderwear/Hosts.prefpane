//
//  PMHostFileModel.h
//  Hosts
//
//  Created by ebone on 09-06-11.
//  Copyright 2011 PermanentMarkers. All rights reserved.
//

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
