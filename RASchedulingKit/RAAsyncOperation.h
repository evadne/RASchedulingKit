//
//  IRAsyncOperation.h
//  RASchedulingKit
//
//  Created by Evadne Wu on 10/10/11.
//  Copyright (c) 2011 Radius. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^IRAsyncOperationInvoker)(void);
typedef void (^RAAsyncOperationCallback)(id results);
typedef void (^RAAsyncOperationWorker)(RAAsyncOperationCallback callback);
typedef void (^RAAsyncOperationTrampoline)(IRAsyncOperationInvoker callback);

@interface RAAsyncOperation : NSOperation <NSCopying>

+ (id) operationWithWorker:(RAAsyncOperationWorker)worker callback:(RAAsyncOperationCallback)callback;

+ (id) operationWithWorker:(RAAsyncOperationWorker)worker trampoline:(RAAsyncOperationTrampoline)workerTrampoline callback:(RAAsyncOperationCallback)callback trampoline:(RAAsyncOperationTrampoline)callbackTrampoline;

@end

extern NSString * const RAAsyncOperationErrorDomain;
