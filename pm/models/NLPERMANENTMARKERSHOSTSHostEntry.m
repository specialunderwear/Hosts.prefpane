//
//  OBHostEntry.m
//  Hosts
//
//  Created by ebone on 13-03-11.
//  Copyright 2011 PermanentMarkers. All rights reserved.
//

#import "NLPERMANENTMARKERSHOSTSHostEntry.h"
#import "c/parser/hosts.h"

@implementation NLPERMANENTMARKERSHOSTSHostEntry

@synthesize use, address, hostnames, comment;

- (id) init {
	[super init];
	use = [NSNumber numberWithInteger:NSOnState];
	address = nil;
	hostnames = nil;
	comment = nil;
	return self;
}

- (id) initWithCHostEntry:(NLPERMANENTMARKERSHOSTS_CHostEntry *) entry {
	use = [NSNumber numberWithInteger:NSOnState];
	address = [NSString alloc];
	hostnames = [NSString alloc];
	comment = [NSString alloc];
	
	if (entry->address != NULL) {
		address = [address initWithCString:entry->address encoding:NSUTF8StringEncoding];
	} else {
		address = [address init];
	}
	
	if (entry->hostnames != NULL) {
		hostnames = [hostnames initWithCString:entry->hostnames encoding:NSUTF8StringEncoding];
	} else {
		hostnames = [hostnames init];
	}
	
	if (entry->comment != NULL) {
		comment = [comment initWithCString:entry->comment encoding:NSUTF8StringEncoding];
	} else {
		comment = [comment init];
	}
	
	return self;
}

- (BOOL) isEqualToHostEntry:(NLPERMANENTMARKERSHOSTSHostEntry *) object {
    return [use isEqualToNumber: object.use] &&
    [address isEqualToString: object.address] &&
    [hostnames isEqualToString: object.hostnames] &&
    [comment isEqualToString: object.comment];
}

- (void) pushUndoState:(NSDictionary *)change withManager:(NSUndoManager *)undoManager forKeyPath:(NSString *) keyPath{
//    NSLog(@"is edit with undoManager %@ can undo %@", undoManager, [undoManager canUndo]);
    id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
    if (oldValue == [NSNull null]) {
        oldValue = nil;
    }
    NSLog(@"old value %@", oldValue);
    [[undoManager prepareWithInvocationTarget:self] setValue:oldValue forKeyPath:keyPath];
    NSString * undoActionName = NSLocalizedStringFromTable(@"Edit", @"HostsAppDelegate",
                                                           @"undo: undo edit");
    [undoManager setActionName:undoActionName];

}

- (void) dealloc {
	[use release];
	[address release];
	[hostnames release];
	[comment release];
	[super dealloc];
}

#pragma mark -
#pragma mark validation

- (BOOL) validateAddress:(id *)ioValue error:(NSError **)outError {
    NSLog(@"validateAddress");
    if (*ioValue != nil && NLPERMANENTMARKERSHOSTS_is_ip_address([*ioValue UTF8String])) {
        NSLog(@"Is ip");
        return YES;
    } else {
        NSLog(@"is not an ip");
        if (outError != NULL) {
            NSString * errorStr = NSLocalizedStringFromTable(@"Please enter a valid ip address", @"NLPERMANENTMARKERSHOSTSHostEntry",
                                                             @"validation: valid ip address");
            NSDictionary * userInfoDict = [NSDictionary dictionaryWithObject:errorStr
                                                                      forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:PM_HOST_ENTRY_ERROR_DOMAIN
                                                  code:PM_HOST_ENTRY_INVALID_IP    
                                              userInfo:userInfoDict];
            *outError = error;
        }
        return NO;
    }
}

- (BOOL) validateArrayOfHostnames:(NSArray *) hostNames {
    BOOL result = YES;
    for (NSString * hostname in hostNames) {
        result = result && NLPERMANENTMARKERSHOSTS_is_hostname([hostname UTF8String]);
    }
    
    return result;
}

- (BOOL) validateHostnames:(id *)ioValue error:(NSError **) outError {
    NSLog(@"hostnames validation");
    NSArray * hostNames = [*ioValue componentsSeparatedByString:@" "];
    if (*ioValue != nil && [self validateArrayOfHostnames:hostNames]) {
        NSLog(@"is hostname");
        return YES;
    } else {
        if (outError != NULL) {
            NSString * errorStr = NSLocalizedStringFromTable(@"Please enter a valid hostname", @"NLPERMANENTMARKERSHOSTSHostEntry",
                                                             @"validation: valid hostname");
            NSDictionary * userInfoDict = [NSDictionary dictionaryWithObject:errorStr
                                                                      forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:PM_HOST_ENTRY_ERROR_DOMAIN
                                                  code:PM_HOST_ENTRY_INVALID_HOSTNAME    
                                              userInfo:userInfoDict];
            *outError = error;
        }
        return NO;
    }
}

#pragma mark coder methods

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:use forKey:@"use"];
    [aCoder encodeObject:address forKey:@"address"];
    [aCoder encodeObject:hostnames forKey:@"hostnames"];
    [aCoder encodeObject:comment forKey:@"comment"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    [super init];
    use = [[aDecoder decodeObjectForKey:@"use"] retain];
    address = [[aDecoder decodeObjectForKey:@"address"] retain];
    hostnames = [[aDecoder decodeObjectForKey:@"hostnames"] retain];
    comment = [[aDecoder decodeObjectForKey:@"comment"] retain];
    return self;
}

#pragma mark observer helpers

- (void)addObserverForAll:(id)observer {
    [self addObserver:observer forKeyPath:@"use" options:NSKeyValueObservingOptionOld context:nil];
    [self addObserver:observer forKeyPath:@"address" options:NSKeyValueObservingOptionOld context:nil];
    [self addObserver:observer forKeyPath:@"hostnames" options:NSKeyValueObservingOptionOld context:nil];
    [self addObserver:observer forKeyPath:@"comment" options:NSKeyValueObservingOptionOld context:nil];
}

- (void)removeAllObservers:(id)observer {
    [self removeObserver:observer forKeyPath:@"use"];
    [self removeObserver:observer forKeyPath:@"address"];
    [self removeObserver:observer forKeyPath:@"hostnames"];
    [self removeObserver:observer forKeyPath:@"comment"];
}

#pragma mark serialize to hosts file

- (NSString *)toString {
    NSString * line;
    if ([comment length] && [address length]) {
        assert([hostnames length]);
        line = [NSString stringWithFormat:@"%@\t%@ %@\n", address, hostnames, comment];
    } else if ([address length]) {
        line = [NSString stringWithFormat:@"%@\t%@\n", address, hostnames];
    } else {
        line = [NSString stringWithFormat:@"%@\n", comment];
    }
    return line;
}

- (void)writeToFileHandle:(NSFileHandle *)handle {
    if ([use integerValue] == NSOnState) {
        NSString *line = [self toString];
        [handle writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

@end
