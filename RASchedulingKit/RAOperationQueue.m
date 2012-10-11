//
//  RAOperationQueue.m
//  RASchedulingKit
//
//  Created by Evadne Wu on 5/31/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import "RAOperationQueue.h"

static NSString * const kRAOperationDispatchQueue = @"+[RAOperationQueue dispatchQueue]";

@interface RAOperationQueue ()

@property (nonatomic, readonly, assign) CFStringRef runLoopMode;
@property (nonatomic, readonly, assign) CFRunLoopObserverRef runLoopObserver;
@property (nonatomic, readwrite, assign) NSUInteger suspendingCount;

+ (dispatch_queue_t) dispatchQueue;

@end


@implementation RAOperationQueue
@synthesize runLoopMode = _runLoopMode;
@synthesize runLoopObserver = _runLoopObserver;
@synthesize suspendingCount = _suspendingCount;

- (id) initWithRunLoopMode:(CFStringRef)mode {

	self = [super init];
	if (!self)
		return nil;
	
	if (mode) {

		__weak typeof(self) wSelf = self;
		
		_runLoopMode = mode;
		_runLoopObserver = CFRunLoopObserverCreateWithHandler(NULL, kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
			[wSelf observeRunLoopWithObserver:observer activity:activity];
		});
		
		CFRunLoopAddObserver(CFRunLoopGetMain(), _runLoopObserver, _runLoopMode);
		
		CFStringRef currentMode = CFRunLoopCopyCurrentMode(CFRunLoopGetMain());
		if (![(__bridge NSString *)currentMode isEqualToString:(__bridge NSString *)_runLoopMode]) {
			[self beginSuspendingOperations];
		}
		
		CFRelease(currentMode);
	
	}
	
	return self;

}

- (void) dealloc {

	if (_runLoopObserver) {
		CFRunLoopRemoveObserver(CFRunLoopGetMain(), _runLoopObserver, _runLoopMode);
		CFRunLoopObserverInvalidate(_runLoopObserver);
		CFRelease(_runLoopObserver);
		_runLoopObserver = nil;
	}

}

- (void) observeRunLoopWithObserver:(CFRunLoopObserverRef)observer activity:(CFRunLoopActivity)activity {

	switch (activity) {
		
		case kCFRunLoopEntry: {
			[self endSuspendingOperations];
			break;
		}
		
		case kCFRunLoopExit: {
			[self beginSuspendingOperations];
			break;
		}
		
		default:
			break;
		
	}

}

- (void) setSuspended:(BOOL)flag {

	[NSException raise:NSInternalInconsistencyException format:@"%s is handled internally by %@ and should not be used by external code.", __PRETTY_FUNCTION__, NSStringFromClass([self class])];
	
	[super setSuspended:flag];

}

- (void) beginSuspendingOperations {

	dispatch_sync([[self class] dispatchQueue], ^{
		
		_suspendingCount += 1;
		
		if (_suspendingCount == 1)
			[super setSuspended:YES];
		
	});

}

- (void) endSuspendingOperations {

	dispatch_sync([[self class] dispatchQueue], ^{
		
		NSCParameterAssert(_suspendingCount);
		_suspendingCount -= 1;
		
		if (_suspendingCount == 0)
			[super setSuspended:NO];
		
	});

}

+ (dispatch_queue_t) dispatchQueue {

	static dispatch_once_t onceToken;
	static dispatch_queue_t dispatchQueue;
	dispatch_once(&onceToken, ^{
		dispatchQueue = dispatch_queue_create([NSStringFromClass([self class]) UTF8String], DISPATCH_QUEUE_SERIAL);
	});
	
	return dispatchQueue;

}

@end
