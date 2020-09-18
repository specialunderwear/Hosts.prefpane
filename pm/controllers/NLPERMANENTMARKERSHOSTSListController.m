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


#import "pm/controllers/NLPERMANENTMARKERSHOSTSListController.h"
#import "pm/models/NLPERMANENTMARKERSHOSTSHostEntry.h"

#define PM_HOST_ENTRY_DATA_TYPE @"nl.permanentmarkers.NLPERMANENTMARKERSHOSTSHostEntry"

@implementation NLPERMANENTMARKERSHOSTSListController

//@synthesize tableView;

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    // filter default rules, comments and empty lines.
    self.clearsFilterPredicateOnInsertion = NO;
    NSString * predicate = @"(NOT (hostnames in { '', 'localhost', 'broadcasthost' }) AND (address != '')) OR (comment == NIL)";
    self.filterPredicate = [NSPredicate predicateWithFormat:predicate];
    return self;
}

- (IBAction) insertHostEntry:(id)sender;
{
    NLPERMANENTMARKERSHOSTSHostEntry * new_entry = [[NLPERMANENTMARKERSHOSTSHostEntry alloc] init];
    
    NSUInteger at_index = [self selectionIndex];
    if (at_index == NSNotFound) {
        [self addObject:new_entry];
        // new item is automatically selected.
        at_index = [self selectionIndex];
    } else {
        [self insertObject:new_entry afterArrangedObjectIndex:at_index];
        at_index++;
    }
    
    [new_entry release];
    [tableView editColumn:1 row:at_index withEvent:nil select:YES];
}

- (IBAction) confirmDeleteItem:(id)sender {
    NSUInteger at_index = [self selectionIndex];
    NLPERMANENTMARKERSHOSTSHostEntry *entry = [[self arrangedObjects] objectAtIndex:at_index];
    
    NSString *title = NSLocalizedStringUniversal(@"Confirm deletion", @"deletion: title");
    NSString *description = NSLocalizedStringUniversal(
            @"Are you sure you want to permanently remove:\n%@ from /etc/hosts?", @"deletion: message format string");
    description = [NSString stringWithFormat:description, [entry toString]];
    NSAlert *alert = [NSAlert alertWithMessageText:title defaultButton:NSLocalizedStringUniversal(@"Yes", nil) alternateButton:NSLocalizedStringUniversal(@"No", nil) otherButton:nil informativeTextWithFormat:@"%@", description];
    [alert beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] modalDelegate:self didEndSelector:@selector(alertEnded:code:context:) contextInfo:NULL];
}

- (void)alertEnded:(NSAlert *)alert code:(int)aChoice context:(void *) v {
    if (aChoice == NSAlertDefaultReturn) {
        [self remove:nil];
    }
}


- (void)insertObject:(id)object afterArrangedObjectIndex:(NSUInteger)index {
    // get selected object and it's index in the content array
    id selected_object = [[self arrangedObjects] objectAtIndex:index];
    NSUInteger real_index = [[self content] indexOfObject:selected_object];
    
    // get binding and send message to insert object in content array.
    // no you can't write to 'content', it is a proxy object.
    NSDictionary * bindingInfo = [self infoForBinding:@"contentArray"];
    [[bindingInfo valueForKey:NSObservedObjectKey]
        insertValue:object atIndex:real_index + 1
        inPropertyWithKey:[bindingInfo valueForKey:NSObservedKeyPathKey]
    ];
    // update view
    [self rearrangeObjects];
    // make tab work correctly.
    [self setSelectionIndex:index + 1];
}

- (id) tableView {
    return tableView;
}

- (void)setTableView:(NSTableView *)tableViewArgument {
    NSLog(@"tableview set");
    [self willChangeValueForKey:@"tableView"];
    tableView = tableViewArgument;
    [tableView registerForDraggedTypes:[NSArray arrayWithObject:PM_HOST_ENTRY_DATA_TYPE]];
    [self didChangeValueForKey:@"tableView"];
}

@end
