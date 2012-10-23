//
//  NSObject+RAScheduling.h
//  RASchedulingKit
//
//  Created by Evadne Wu on 5/31/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RAAsyncOperation.h"

@interface NSObject (RAScheduling)

- (NSOperationQueue *) ra_newOperationQueue;

- (void) ra_performBlock:(void(^)(void))block;
- (void) ra_performDeferrableBlock:(void(^)(RAAsyncOperationCallback callback))block;
- (void) ra_cancelBlocks;

- (void) ra_beginSuspendingBlocks;
- (void) ra_endSuspendingBlocks;

@end
