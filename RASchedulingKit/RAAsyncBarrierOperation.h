//
//  IRAsyncBarrierOperation.h
//  RASchedulingKit
//
//  Created by Evadne Wu on 4/6/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import "RAAsyncOperation.h"

@interface RAAsyncBarrierOperation : RAAsyncOperation

- (void) addDependency:(RAAsyncOperation *)op;

@end
