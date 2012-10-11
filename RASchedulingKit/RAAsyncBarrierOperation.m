//
//  IRAsyncBarrierOperation.m
//  RASchedulingKit
//
//  Created by Evadne Wu on 4/6/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import "RAAsyncBarrierOperation.h"
#import "RAAsyncOperation+ForSubclassEyesOnly.h"


@interface RAAsyncBarrierOperation ()

- (BOOL) hasFailedDependency;

@end


@implementation RAAsyncBarrierOperation

- (void) addDependency:(RAAsyncOperation *)op {

	NSParameterAssert([op isKindOfClass:[RAAsyncOperation class]]);
	[super addDependency:op];

}

- (BOOL) hasFailedDependency {

	for (RAAsyncOperation *op in self.dependencies)
	if ([op isCancelled] || ([op isFinished] && (!op.results || [op.results isKindOfClass:[NSError class]])))
		return YES;
	
	return NO;

}

- (void) main {

	if ([self hasFailedDependency]) {
	
		self.workerTrampoline(^ {
			
			[self handleResult:[NSError errorWithDomain:RAAsyncOperationErrorDomain code:0 userInfo:@{
			
				NSLocalizedDescriptionKey: @"Operation is not going to run its worker block because a dependent operation has failed"
			
			}]];
			
		});
				
		return;
	
	}

	[super main];
	
}

@end
