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

#import "pm/auth/NLPERMANENTMARKERSHOSTSAuthorization.h"
#import "pm/NLPERMANENTMARKERSHOSTSConstants.h"
#import "pm/utils/NLPERMANENTMARKERSHOSTSFileWriter.h"

@implementation NLPERMANENTMARKERSHOSTSAuthorization

- (void) conditionallyInstallAuthorizationRule {
    AuthorizationRef hostsAuthorizationRef = [[authView authorization] authorizationRef];
    OSStatus updateRightsStatus;
    CFDictionaryRef registeredRights = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    // store rights dictionary in registeredRights.
    AuthorizationRightGet(PM_AUTHORISED_FILE, &registeredRights);
    
    NSString * rule = [(__bridge NSDictionary *)registeredRights valueForKey:@"comment"];
    if ([rule isEqualToString:@PM_AUTHENTICATION_RULE_COMMENT]) {
        NSLog(@"the rule is correct");
    } else {
        [NLPERMANENTMARKERSHOSTSFileWriter backupHostsFileWithExtension:@"orig"];
        NSArray *keys = [NSArray arrayWithObjects:@"class", @"comment", @"group", @"shared", @"timeout" , nil];
        NSArray *values = [NSArray arrayWithObjects:@"user", @PM_AUTHENTICATION_RULE_COMMENT, @"admin", [NSNumber numberWithBool:YES], [NSNumber numberWithInt:300], nil];
        NSDictionary *rightDefinition = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        updateRightsStatus = AuthorizationRightSet(hostsAuthorizationRef, PM_AUTHORISED_FILE,
                                                   (__bridge CFDictionaryRef)rightDefinition,
                                                   NULL, NULL, NULL);
        if (updateRightsStatus == errAuthorizationSuccess) {
            NSLog(@"i could write the right");
        } else {
            // TODO: raise error.
        }
    }
    CFRelease(registeredRights);
}

- (id) initWithAuthView:(SFAuthorizationView *) anAuthView {
    self = [super init];

    if (self) {
        authView = anAuthView;
        
        AuthorizationItem hostsAuthorizationItems[2];
        hostsAuthorizationItems[0].name = PM_AUTHENTICATION_RULE;
        hostsAuthorizationItems[0].valueLength = 0;
        hostsAuthorizationItems[0].value = NULL;
        hostsAuthorizationItems[0].flags = 0;
        hostsAuthorizationItems[1].name = PM_AUTHORISED_FILE;
        hostsAuthorizationItems[1].valueLength = 0;
        hostsAuthorizationItems[1].value = NULL;
        hostsAuthorizationItems[1].flags = 0;

        hostFileRights.count = 2;
        hostFileRights.items = hostsAuthorizationItems;

        [authView setAuthorizationRights:&hostFileRights];
        [authView updateStatus:self];
        [authView setAutoupdate:YES];
    }
    return self;
}

- (void) obtain {
    [authView authorize:self];
}


@end
