//
//  OBHostEntry.h
//  Hosts
//
//  Created by ebone on 13-03-11.
//  Copyright 2011 PermanentMarkers. All rights reserved.
//

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
@property(readonly, copy) NSString *comment;

@end
