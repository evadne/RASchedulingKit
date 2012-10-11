//
//  IRAsyncOperation.m
//  RASchedulingKit
//
//  Created by Evadne Wu on 10/10/11.
//  Copyright (c) 2011 Radius. All rights reserved.
//

#import "RAAsyncOperation.h"
#import "RAAsyncOperation+ForSubclassEyesOnly.h"


NSString * const RAAsyncOperationErrorDomain = @"radius.asyncOperation.error";


@interface RAAsyncOperation ()

@property (nonatomic, readwrite, copy) RAAsyncOperationWorker worker;
@property (nonatomic, readwrite, copy) RAAsyncOperationTrampoline workerTrampoline;

@property (nonatomic, readwrite, copy) RAAsyncOperationCallback callback;
@property (nonatomic, readwrite, copy) RAAsyncOperationTrampoline callbackTrampoline;

@property (nonatomic, readonly, assign, getter=isExecuting) BOOL executing;
@property (nonatomic, readonly, assign, getter=isFinished) BOOL finished;

@property (nonatomic, readwrite, strong) id results;

@end


@implementation RAAsyncOperation

@synthesize executing, finished;
@synthesize worker, workerTrampoline, callback, callbackTrampoline;
@synthesize results;

+ (id) operationWithWorker:(RAAsyncOperationWorker)inWorker trampoline:(RAAsyncOperationTrampoline)inWorkerTrampoline callback:(RAAsyncOperationCallback)inCallback trampoline:(RAAsyncOperationTrampoline)inCallbackTrampoline {

	RAAsyncOperation *op = [[self alloc] init];
	
	op.worker = inWorker;
	op.workerTrampoline = inWorkerTrampoline;
	op.callback = inCallback;
	op.callbackTrampoline = inCallbackTrampoline;
	
	return op;

}

+ (id) operationWithWorker:(RAAsyncOperationWorker)inWorker callback:(RAAsyncOperationCallback)inCallback {

	return [self operationWithWorker:inWorker trampoline:[self copyDefaultWorkerTrampoline] callback:inCallback trampoline:[self copyDefaultCallbackTrampoline]];

}

- (id) copyWithZone:(NSZone *)zone {

	RAAsyncOperation *op = [[[self class] alloc] init];
	
	op.worker = worker;
	op.workerTrampoline = workerTrampoline;
	
	op.callback = callback;
	op.callbackTrampoline = callbackTrampoline;
	
	op.results = results;
	
	return op;

}

- (BOOL) isConcurrent {

	return YES;

}

- (void) setFinished:(BOOL)newFinished {

	if (newFinished == finished)
		return;
	
	[self willChangeValueForKey:@"isFinished"];
	[self willChangeValueForKey:@"progress"];
	
	finished = newFinished;
	
	[self didChangeValueForKey:@"progress"];
	[self didChangeValueForKey:@"isFinished"];

}

- (void) setExecuting:(BOOL)newExecuting {

	if (newExecuting == executing)
		return;
	
	[self willChangeValueForKey:@"isExecuting"];
	executing = newExecuting;
	[self didChangeValueForKey:@"isExecuting"];

}

- (void) handleResult:(id)incomingResults {

	if ([self isCancelled])
		return;
	
	self.callbackTrampoline(^ {
		
		self.results = incomingResults;
		
		if (self.callback)
			self.callback(self.results);
		
		self.executing = NO;
		self.finished = YES;
		
	});
	
}

- (void) start {

	if ([self isCancelled]) {
		self.finished = YES;
		return;
	}
	
	self.executing = YES;
	
	[self main];

}

- (void) main {

	self.workerTrampoline(^ {
		
		if (self.worker) {
			
			self.worker([ ^ (id incomingResults) {
				[self handleResult:incomingResults];
			} copy]);
		
		}
		
	});

}

- (void) cancel {

	[super cancel];

	if (self.executing)
		self.finished = YES;
	
	self.executing = NO;
	
	if (self.callback)
		self.callback(nil);
	
}

+ (RAAsyncOperationTrampoline) copyDefaultWorkerTrampoline {

	return [^(void(^workerInvoker)(void)) {
	
		dispatch_async(dispatch_get_main_queue(), workerInvoker);
	
	} copy];

}

+ (RAAsyncOperationTrampoline) copyDefaultCallbackTrampoline {

	return [^(void(^callbackInvoker)(void)) {
	
		dispatch_async(dispatch_get_main_queue(), callbackInvoker);
	
	} copy];

}

@end
