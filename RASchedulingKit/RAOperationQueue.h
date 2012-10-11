//
//  RAOperationQueue.h
//  RASchedulingKit
//
//  Created by Evadne Wu on 5/31/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RAOperationQueue : NSOperationQueue

- (id) initWithRunLoopMode:(CFStringRef)mode;	//	NULL for all modes

- (void) beginSuspendingOperations;
- (void) endSuspendingOperations;

@end
