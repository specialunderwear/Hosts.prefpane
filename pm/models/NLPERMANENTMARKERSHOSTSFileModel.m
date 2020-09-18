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

#import "c/parser/hostsparser.h"
#import "pm/NLPERMANENTMARKERSHOSTSConstants.h"
#import "pm/models/NLPERMANENTMARKERSHOSTSFileModel.h"
#import "pm/models/NLPERMANENTMARKERSHOSTSHostEntry.h"
#import "pm/utils/NLPERMANENTMARKERSHOSTSFileWriter.h"
#import "pm/utils/NLPERMANENTMARKERSHOSTSParserCallbacks.h"

// The hosts array, initialized by NLPERMANENTMARKERSHOSTSFileModel.initialize
NSMutableArray * NLPERMANENTMARKERSHOSTShostsEntries;

@implementation NLPERMANENTMARKERSHOSTSFileModel

@synthesize undoManager, authorization;

#pragma mark class methods
+ (void) initialize {
    if (self == [NLPERMANENTMARKERSHOSTSFileModel class]) {
        // initialize hosts array
        NLPERMANENTMARKERSHOSTShostsEntries = [NSMutableArray new];
        
        // initialize hosts default storage.
        NSData * current_hosts_archive = [NSKeyedArchiver archivedDataWithRootObject:NLPERMANENTMARKERSHOSTShostsEntries];
        NSMutableDictionary *defaults = [NSMutableDictionary dictionaryWithObject:current_hosts_archive forKey:PMHOSTS_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    }
}

#pragma mark kvc compliance for hosts key

- (NSUInteger) countOfHosts {
    return [NLPERMANENTMARKERSHOSTShostsEntries count];
}

- (id) objectInHostsAtIndex: (NSUInteger) index {
    return [NLPERMANENTMARKERSHOSTShostsEntries objectAtIndex:index];
}

- (id) objectInHostsAtIndexes: (NSIndexSet *) range {
    return [NLPERMANENTMARKERSHOSTShostsEntries objectsAtIndexes:range];
}

- (void)getHosts:(id *)aBuffer range:(NSRange)aRange {
    return [NLPERMANENTMARKERSHOSTShostsEntries getObjects:aBuffer range:aRange];
}

- (void) insertObject:(id)object inHostsAtIndex:(NSUInteger) index {
    NSLog(@"inserting in hosts");
    [NLPERMANENTMARKERSHOSTShostsEntries insertObject:object atIndex:index];
    [object addObserverForAll:self];
    if (undoManager != nil) {
        [[undoManager prepareWithInvocationTarget:self] removeObjectFromHostsAtIndex:index];
        if ([undoManager isUndoing]) {
            NSString * undoActionName = NSLocalizedStringUniversal(@"Delete host entry", @"undo: redo insert");
            [undoManager setActionName:undoActionName];
        } else {
            NSString * undoActionName = NSLocalizedStringUniversal(@"Insert host entry", @"undo: undo delete");
            [undoManager setActionName:undoActionName];
        }
    }
}

- (void) removeObjectFromHostsAtIndex:(NSUInteger) index {
    if (undoManager != nil) {
        NLPERMANENTMARKERSHOSTSHostEntry * deletedObject = [NLPERMANENTMARKERSHOSTShostsEntries objectAtIndex:index];
        [undoManager removeAllActionsWithTarget:deletedObject];
        [[undoManager prepareWithInvocationTarget:self] insertObject:deletedObject inHostsAtIndex:index];
        if ([undoManager isUndoing]) {
            NSString * undoActionName = NSLocalizedStringUniversal(@"Insert host entry", @"undo: redo delete");
            [undoManager setActionName:undoActionName];
        } else {
            NSString * undoActionName = NSLocalizedStringUniversal(@"Delete host entry", @"undo: undo insert");
            [undoManager setActionName:undoActionName];        
        }
    }
    [[NLPERMANENTMARKERSHOSTShostsEntries objectAtIndex:index] removeAllObservers:self];
    [NLPERMANENTMARKERSHOSTShostsEntries removeObjectAtIndex:index];
}

- (NSMutableArray *) hosts {
    return NLPERMANENTMARKERSHOSTShostsEntries;
}

- (void) setHosts:(NSMutableArray *)hosts {
    if (! [hosts isEqualTo:NLPERMANENTMARKERSHOSTShostsEntries]) {
        [self willChangeValueForKey:@"hosts"];
        [hosts retain];
        [NLPERMANENTMARKERSHOSTShostsEntries release];
        NLPERMANENTMARKERSHOSTShostsEntries = hosts;
        [self didChangeValueForKey:@"hosts"];
        assert(NO);
    }
}

#pragma mark drag and drop
- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    // Copy the row numbers to the pasteboard.
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:PM_HOST_ENTRY_DATA_TYPE] owner:self];
    [pboard setData:data forType:PM_HOST_ENTRY_DATA_TYPE];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op
{
    // Add code here to validate the drop
    NSLog(@"validate Drop");
    if (op == NSTableViewDropOn || row >= [tv numberOfRows]) {
        return NSDragOperationNone;
    }
    return NSDragOperationEvery;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info
              row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
    NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:PM_HOST_ENTRY_DATA_TYPE];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    NSInteger dragRow = [rowIndexes firstIndex];
    
    // Move the specified row to its new location...
    NLPERMANENTMARKERSHOSTSHostEntry * entry = [[controller arrangedObjects] objectAtIndex:dragRow];
    NLPERMANENTMARKERSHOSTSHostEntry * targetEntry = [[controller arrangedObjects] objectAtIndex:row];
    
    NSUInteger index = [NLPERMANENTMARKERSHOSTShostsEntries indexOfObject:entry];
    [self removeObjectFromHostsAtIndex:index];
    
    NSUInteger targetIndex = [NLPERMANENTMARKERSHOSTShostsEntries indexOfObject:targetEntry];
    [self insertObject:entry inHostsAtIndex:targetIndex];
    
    return YES;
}


#pragma mark observers

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    [authorization obtain];
    
    if (undoManager != nil && [object isKindOfClass:[NLPERMANENTMARKERSHOSTSHostEntry class]]) {
        [object pushUndoState:change withManager:undoManager forKeyPath:keyPath];
    }
    
    // disable sudden termination to make sure that we don't get the defaults and /etc/hosts running out of sync.
    [[NSProcessInfo processInfo] disableSuddenTermination];
    // update stored defaults
    NSData * current_hosts_archive = [NSKeyedArchiver archivedDataWithRootObject:NLPERMANENTMARKERSHOSTShostsEntries];
    [[NSUserDefaults standardUserDefaults] setObject:current_hosts_archive forKey:PMHOSTS_DEFAULTS_KEY];
    
    // update /etc/hosts
    [writer writeHostEntries:NLPERMANENTMARKERSHOSTShostsEntries];
    [[NSProcessInfo processInfo] enableSuddenTermination];
}


//
#pragma mark private methods
- (void) insertInactiveItems:(NSMutableArray *)parsed_data {
    NSData * stored_items_data = [[NSUserDefaults standardUserDefaults] objectForKey:PMHOSTS_DEFAULTS_KEY];
    NSMutableArray * stored_items = [NSKeyedUnarchiver unarchiveObjectWithData:stored_items_data];
    [stored_items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[obj use] integerValue] == NSOffState) {
            @try {
                [NLPERMANENTMARKERSHOSTShostsEntries insertObject:obj atIndex:idx];
            }
            @catch (NSException *exception) {
                [NLPERMANENTMARKERSHOSTShostsEntries addObject:obj];
            }
        }
    }];
}

#pragma mark initializers
- (id)init
{
    self = [super init];
    if (self) {
        writer = [[NLPERMANENTMARKERSHOSTSFileWriter alloc] init];
        [NLPERMANENTMARKERSHOSTSFileWriter backupHostsFileWithExtension:@"session"];
        
        // parse hosts file.
        needsLoad = YES;
        [self load];
    }
    
    return self;
}

- (void) clear {
    NSLog(@"reset called");
    for (NLPERMANENTMARKERSHOSTSHostEntry * entry in NLPERMANENTMARKERSHOSTShostsEntries) {
        [entry removeAllObservers:self];
    }
    // remove observer before clearing array to avoid update of hosts file.
    [self removeObserver:self forKeyPath:@"hosts"];
    [NLPERMANENTMARKERSHOSTShostsEntries removeAllObjects];
    
    needsLoad = YES;
}

-(void) load {
    NSLog(@"Load called");
    if (needsLoad) {
        [self willChangeValueForKey:@"hosts"];
        NSLog(@"Load was needed");
        [[NSProcessInfo processInfo] disableSuddenTermination];
        [NLPERMANENTMARKERSHOSTSFileWriter backupHostsFileWithExtension:@"session"];
        NLPERMANENTMARKERSHOSTSparsefile(PM_HOSTS_FILE_LOCATION, NLPERMANENTMARKERSHOSTSonHostEntryFound, NLPERMANENTMARKERSHOSTSonHostsParseError);
        
        [self insertInactiveItems:NLPERMANENTMARKERSHOSTShostsEntries];
        
        // observe for existing items for changes.
        for (NLPERMANENTMARKERSHOSTSHostEntry * entry in NLPERMANENTMARKERSHOSTShostsEntries) {
            [entry addObserverForAll:self];
        }
        
        // observe hosts array for inserts and removal.
        [self addObserver:self forKeyPath:@"hosts" options:0 context:nil];
        needsLoad = NO;
        [[NSProcessInfo processInfo] enableSuddenTermination];
        [self didChangeValueForKey:@"hosts"];
    }
}

//
- (void)dealloc
{
    [NLPERMANENTMARKERSHOSTShostsEntries release];
    [undoManager release];
    [authorization release];
    [writer release];
    
    [super dealloc];
}

@end
