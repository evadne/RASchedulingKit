//
//  NSObject+RAScheduling.m
//  RASchedulingKit
//
//  Created by Evadne Wu on 5/31/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+RAScheduling.h"
#import "RAOperationQueue.h"
#import "RAAsyncOperation.h"

static NSString * const kQueue = @"-[UIViewController(IRDelayedUpdateAdditions) queue]";

@implementation NSObject (RAScheduling)

- (RAOperationQueue *) ra_operationQueue {

	RAOperationQueue *queue = objc_getAssociatedObject(self, &kQueue);
	if (!queue) {
		queue = [[RAOperationQueue alloc] init];
		queue.maxConcurrentOperationCount = 1;
		objc_setAssociatedObject(self, &kQueue, queue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return queue;

}

- (void) ra_performBlock:(void(^)(void))block {

	NSOperation *op = [RAAsyncOperation operationWithWorker:^(RAAsyncOperationCallback callback) {
	
		block();
		callback((id)kCFBooleanTrue);
		
	} trampoline:^(IRAsyncOperationInvoker block) {
		
		dispatch_async(dispatch_get_main_queue(), block);
		
	} callback:nil trampoline:^(IRAsyncOperationInvoker block) {
		
		dispatch_async(dispatch_get_main_queue(), block);
		
	}];

	[self.ra_operationQueue addOperation:op];

}

- (void) ra_cancelBlocks {

	[self.ra_operationQueue cancelAllOperations];

}

@end
