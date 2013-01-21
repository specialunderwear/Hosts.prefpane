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

#import "pm/controllers/NLPERMANENTMARKERSHOSTSAppController.h"
#import "pm/NLPERMANENTMARKERSHOSTSConstants.h"
#import "pm/models/NLPERMANENTMARKERSHOSTSHostEntry.h"

@implementation NLPERMANENTMARKERSHOSTSAppController

@synthesize hostfile;

- (void) setUp:(NSUndoManager *)undoManager {
    // Insert code here to initialize your application
    
	NSLog(@"setUp");
    hostfile.undoManager = undoManager;
    NSLog(@"undomanager is %@", hostfile.undoManager);
    
    // initialize authorisation settings
    authorization = [[NLPERMANENTMARKERSHOSTSAuthorization alloc] initWithAuthView:authView];
    hostfile.authorization = authorization;
    authView.delegate = self;
    disableAllCheckbox.state = [[[NSUserDefaults standardUserDefaults] objectForKey:PMHOSTS_DISABLE_ALL_KEY] intValue];

    [self willChangeValueForKey:@"authenticated"];
    [self didChangeValueForKey:@"authenticated"];
}

#pragma mark authorisation delegates
- (void)authorizationViewDidAuthorize:(SFAuthorizationView *)view {
    NSLog(@"i can do what i want");
    [authorization conditionallyInstallAuthorizationRule];
    [self willChangeValueForKey:@"authenticated"];
    [self didChangeValueForKey:@"authenticated"];
}

- (void)authorizationViewDidDeauthorize:(SFAuthorizationView *)view {
    NSLog(@"I can not do what i want");
    [self willChangeValueForKey:@"authenticated"];
    [self didChangeValueForKey:@"authenticated"];
}

- (BOOL)isAuthenticated{
    return [authView authorizationState] == SFAuthorizationViewUnlockedState;
}

#pragma mark disable all
- (IBAction) disableAll:(id)sender {
    NSLog(@"Changing state %li", [sender state]);
    @synchronized(sender) {
        NSString * predicate = @"(NOT (hostnames in { '', 'localhost', 'broadcasthost' }) AND (address != '')) OR (comment == NIL)";
        NSPredicate *filter = [NSPredicate predicateWithFormat:predicate];
        NSArray *hosts = [hostfile.hosts filteredArrayUsingPredicate:filter];
        if (disableAllCheckbox.state == NSOnState) {
            for (NLPERMANENTMARKERSHOSTSHostEntry *entry in hosts) {
                entry.disabled = entry.use;
                entry.use = [NSNumber numberWithInt:NSOffState];
            }
        } else {
            for (NLPERMANENTMARKERSHOSTSHostEntry *entry in hosts) {
                entry.use = entry.disabled;
                entry.disabled = [NSNumber numberWithBool:NO];
            }
        }
    }
}


@end
