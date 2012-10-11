//
//  IRAsyncOperation+ForSubclassEyesOnly.h
//  RASchedulingKit
//
//  Created by Evadne Wu on 4/6/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import "RAAsyncOperation.h"

@interface RAAsyncOperation (SubclassEyesOnly)

@property (nonatomic, readonly, copy) RAAsyncOperationWorker worker;
@property (nonatomic, readonly, copy) RAAsyncOperationTrampoline workerTrampoline;

@property (nonatomic, readonly, copy) RAAsyncOperationCallback callback;
@property (nonatomic, readonly, copy) RAAsyncOperationTrampoline callbackTrampoline;

@property (nonatomic, readonly, assign, getter=isExecuting) BOOL executing;
@property (nonatomic, readonly, assign, getter=isFinished) BOOL finished;

@property (nonatomic, readonly, strong) id results;

- (void) handleResult:(id)incomingResults;

- (RAAsyncOperationTrampoline) copyDefaultWorkerTrampoline;
- (RAAsyncOperationTrampoline) copyDefaultCallbackTrampoline;

@end
