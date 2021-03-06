//
//  IRAsyncOperationTest.m
//  RASchedulingKit
//
//  Created by Evadne Wu on 4/6/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import "RAAsyncOperationTest.h"
#import "RAAsyncOperation.h"
#import "RAAsyncBarrierOperation.h"

#import <objc/runtime.h>

@implementation RAAsyncOperationTest

- (void) testOperationSerialQueueing {

	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	[queue setMaxConcurrentOperationCount:1];
	
	NSMutableArray *operations = [NSMutableArray array];
	
	RAAsyncOperation * (^operation)(void) = ^ {
	
		NSString *result = (__bridge NSString *)(CFUUIDCreateString(NULL, CFUUIDCreate(NULL)));
	
		__block RAAsyncOperation *operation = [RAAsyncOperation operationWithWorker:^(RAAsyncOperationCallback callback) {
		
			STAssertTrue([NSThread isMainThread], @"Operation %@ must be running its worker block on the main thread", self);
			NSUInteger ownIndex = [operations indexOfObject:operation];
			STAssertFalse(ownIndex == NSNotFound, @"Operation %@ must be tracked by the test case", operation);
			
			[operations enumerateObjectsUsingBlock:^(NSOperation *otherOp, NSUInteger idx, BOOL *stop) {
				
				if (idx < ownIndex) {

					STAssertFalse([otherOp isExecuting], @"Previous operation %@ must not be executing", otherOp);
					STAssertTrue([otherOp isFinished], @"Previous operation %@ must have finished", otherOp);
					STAssertFalse([otherOp isCancelled], @"Previous operation %@ must have not been cancelled", otherOp);
				
				} else if (idx == ownIndex) {
				
					//	No op
				
				} else {
				
					STAssertFalse([otherOp isExecuting], @"Further operation %@ must not be executing", otherOp);
					STAssertFalse([otherOp isFinished], @"Further operation %@ must have not finished", otherOp);
					STAssertFalse([otherOp isCancelled], @"Further operation %@ must have not been cancelled", otherOp);
				
				}
				
			}];
			
			callback(result);
			
		} callback: ^ (id results) {
		
			STAssertEqualObjects(results, result, @"Result must be passed correctly, as exactly the same object");
			
			STAssertTrue([NSThread isMainThread], @"Operation %@ must be running its completion block on the main thread", self);
			NSUInteger ownIndex = [operations indexOfObject:operation];
			STAssertFalse(ownIndex == NSNotFound, @"Operation %@ must be tracked by the test case", operation);
			
			[operations enumerateObjectsUsingBlock:^(NSOperation *otherOp, NSUInteger idx, BOOL *stop) {
				
				if (idx < ownIndex) {

					STAssertFalse([otherOp isExecuting], @"Previous operation %@ must not be executing", otherOp);
					STAssertTrue([otherOp isFinished], @"Previous operation %@ must have finished", otherOp);
					STAssertFalse([otherOp isCancelled], @"Previous operation %@ must have not been cancelled", otherOp);
				
				} else if (idx == ownIndex) {
				
					//	No op
				
				} else {
				
					STAssertFalse([otherOp isExecuting], @"Further operation %@ must not be executing", otherOp);
					STAssertFalse([otherOp isFinished], @"Further operation %@ must have not finished", otherOp);
					STAssertFalse([otherOp isCancelled], @"Further operation %@ must have not been cancelled", otherOp);
				
				}
				
			}];
			
			operation = nil;
			
		}];
		
		return operation;

	};
	
	for (int i = 0; i < 100; i++)
		[operations addObject:operation()];
	
	[queue addOperations:operations waitUntilFinished:NO];

	while (queue.operationCount)
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:5]];

}

- (void) testBarrierOperation {

	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	[queue setMaxConcurrentOperationCount:1];
	
	NSMutableArray *operations = [NSMutableArray array];
	RAAsyncBarrierOperation * (^operation)(BOOL, BOOL, BOOL, BOOL) = ^ (BOOL assertWorkerNotReached, BOOL throwFailure, BOOL assertFailure, BOOL assertSuccess) {
	
		__block RAAsyncBarrierOperation *operation = [RAAsyncBarrierOperation operationWithWorker:^(RAAsyncOperationCallback callback) {
		
			NSUInteger ownIndex = [operations indexOfObject:operation];
			STAssertFalse(ownIndex == NSNotFound, @"Operation %@ must be tracked by the test case", operation);
			
			if (assertWorkerNotReached)
				STFail(@"Worker block should not be reached in operation %@ (index %lu)", operation, (long)ownIndex);
			
			callback(throwFailure ? [NSError errorWithDomain:@"com.iridia.asyncOperation.mockError" code:0 userInfo:nil] : (id)kCFBooleanTrue);
		
		} callback: ^ (id results) {
		
			if (assertFailure)
				STAssertTrue([results isKindOfClass:[NSError class]], @"Operation should get an error");

			if (assertSuccess)
				STAssertFalse([results isKindOfClass:[NSError class]], @"Operation should not get an error");
			
			operation = nil;
		
		}];
		
		RAAsyncOperation *lastOp = [operations lastObject];
		if (lastOp)
			[operation addDependency:lastOp];
		
		return operation;
	
	};
	
	//	Other operations bail after first simulated operation failed
	//	If the operation comes after the failing operation, its worker block should not be reached
	//	If the operation index is the failing one it should throw a failure
	//	Any operation after the failing one, including the failing one, fails
	//	Any operation before the failing one should not fail
	
	NSUInteger const failingOperationIndex = 25;
	
	for (int i = 0; i < 100; i++)
		[operations addObject:operation((i > failingOperationIndex), (i == failingOperationIndex), (i >= failingOperationIndex), (i < failingOperationIndex))];

	[queue addOperations:operations waitUntilFinished:NO];

	while (queue.operationCount)
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:5]];

}

@end
