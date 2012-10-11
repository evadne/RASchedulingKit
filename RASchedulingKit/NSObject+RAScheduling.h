//
//  NSObject+RAScheduling.h
//  RASchedulingKit
//
//  Created by Evadne Wu on 5/31/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (RAScheduling)

@property (nonatomic, readonly, strong) NSOperationQueue *ra_operationQueue;

- (void) ra_performBlock:(void(^)(void))block;
- (void) ra_cancelBlocks;

@end
