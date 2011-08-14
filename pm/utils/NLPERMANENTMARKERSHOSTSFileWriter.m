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

#import "pm/NLPERMANENTMARKERSHOSTSConstants.h"
#import "pm/utils/NLPERMANENTMARKERSHOSTSFileWriter.h"
#import "pm/models/NLPERMANENTMARKERSHOSTSHostEntry.h"

@implementation NLPERMANENTMARKERSHOSTSFileWriter

+ (void) backupHostsFileWithExtension:(NSString *)extension {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *folder = @"~/Library/Application Support/Hosts/";
    folder = [folder stringByExpandingTildeInPath];
    
    if ([fileManager fileExistsAtPath: folder] == NO)
    {
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *fileName = [NSString stringWithFormat:@"hosts.%@", extension];
    folder = [folder stringByAppendingPathComponent: fileName];
    NSLog(@"copying %@ to %@", @PM_HOSTS_FILE_LOCATION, folder);
    [fileManager copyItemAtPath:@PM_HOSTS_FILE_LOCATION toPath:folder error:nil];
}

- (id) initWithAuthorization:(NLPERMANENTMARKERSHOSTSAuthorization *) aNauthorization {
    self = [super init];
    if (self) {
        authorization = aNauthorization;
        [authorization retain];
    }
    return self;
}

- (void) writeHostEntries:(NSArray *)hostEntries {
    [authorization obtain];
    [[NSProcessInfo processInfo] disableSuddenTermination];
    // update /etc/hosts
    NSPipe * stdIn = [NSPipe pipe];
    NSTask * hostsWriter = [[NSTask alloc] init];
    [hostsWriter setLaunchPath:@"/usr/libexec/authopen"];
    [hostsWriter setArguments:[NSArray arrayWithObjects:@"-w", @PM_HOSTS_FILE_LOCATION, nil]];
    [hostsWriter setStandardInput:stdIn];
    NSFileHandle * stdInHandle = [stdIn fileHandleForWriting];
    
    // write hosts data to stdin of hostWriter, so it gets written to /etc/hosts.
    for (NLPERMANENTMARKERSHOSTSHostEntry * entry in hostEntries) {
        [entry writeToFileHandle:stdInHandle];
    }
    [stdInHandle closeFile];
    
    [hostsWriter launch];
    [hostsWriter waitUntilExit];
    [hostsWriter release];
    [[NSProcessInfo processInfo] enableSuddenTermination];
}

- (void) dealloc {
    [authorization release];
    [super dealloc];
}

@end
