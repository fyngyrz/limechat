// Created by Satoshi Nakagawa.
// You can redistribute it and/or modify it under the Ruby's license or the GPL2.

#import "FileLogger.h"
#import "Preferences.h"
#import "NSStringHelper.h"


@interface FileLogger (Private)
- (void)open;
- (NSString*)buildFileName;
@end


@implementation FileLogger

@synthesize client;
@synthesize channel;

- (id)init
{
	if (self = [super init]) {
	}
	return self;
}

- (void)dealloc
{
	[fileName release];
	[file release];
	[super dealloc];
}

- (void)close
{
	if (file) {
		[file closeFile];
		[file release];
		file = nil;
	}
}

- (void)writeLine:(NSString*)s
{
	[self open];
	
	if (file) {
		s = [s stringByAppendingString:@"\n"];
		
		NSData* data = [s dataUsingEncoding:NSUTF8StringEncoding];
		if (!data) {
			data = [s dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
		}
		
		if (data) {
			[file writeData:data];
		}
	}
}

- (void)reopenIfNeeded
{
	if (!fileName || ![fileName isEqualToString:[self buildFileName]]) {
		[self open];
	}
}

- (void)open
{
	[self close];
	
	[fileName release];
	fileName = [[self buildFileName] retain];
	
	NSString* dir = [fileName stringByDeletingLastPathComponent];
	
	NSFileManager* fm = [NSFileManager defaultManager];
	BOOL isDir = NO;
	if (![fm fileExistsAtPath:dir isDirectory:&isDir]) {
		[fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	
	if (![fm fileExistsAtPath:fileName]) {
		[fm createFileAtPath:fileName contents:[NSData data] attributes:nil];
	}
	
	[file release];
	file = [[NSFileHandle fileHandleForUpdatingAtPath:fileName] retain];
	if (file) {
		[file seekToEndOfFile];
	}
}

- (NSString*)buildFileName
{
	NSString* base = [NewPreferences stringForKey:@"Preferences.General.transcript_folder"];
	base = [base stringByExpandingTildeInPath];
	
	static NSDateFormatter* format = nil;
	if (!format) {
		format = [NSDateFormatter new];
		[format setDateFormat:@"YYYY-MM-dd"];
	}
	NSString* date = [format stringFromDate:[NSDate date]];
	NSString* name = [[client name] safeFileName];
	NSString* pre = @"";
	NSString* c = @"";
	
	// ### isTalk is not working now
	
	if (!channel) {
		c = @"Console";
	}
	else if ([channel isTalk] == 1) {
		c = @"Talk";
		pre = [[[channel name] safeFileName] stringByAppendingString:@"_"];
	}
	else {
		c = [[channel name] safeFileName];
	}
	
	return [base stringByAppendingFormat:@"/%@/%@%@_%@.txt", c, pre, date, name];
}

@end
