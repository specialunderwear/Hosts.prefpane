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
    
    // We do not really change the value here, but we inform that it has changed
    // (actual value is from SFAuthorizationViewUnlockedState)
    [self willChangeValueForKey:@"authenticated"];
    [self didChangeValueForKey:@"authenticated"];
}

#pragma mark authorisation delegates


- (void)authorizationViewDidAuthorize:(SFAuthorizationView *)view {
    NSLog(@"i can do what i want");
    [authorization conditionallyInstallAuthorizationRule];

    // see above
    [self willChangeValueForKey:@"authenticated"];
    [self didChangeValueForKey:@"authenticated"];
}

- (void)authorizationViewDidDeauthorize:(SFAuthorizationView *)view {
    NSLog(@"I can not do what i want");
    
    // see above
    [self willChangeValueForKey:@"authenticated"];
    [self didChangeValueForKey:@"authenticated"];
}

- (BOOL)isAuthenticated{
    return [authView authorizationState] == SFAuthorizationViewUnlockedState;
}

@end
