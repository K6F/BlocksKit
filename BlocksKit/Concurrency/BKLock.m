//
//  BKLock.m
//  BlocksKit
//
//  Created by Andrew Romanov on 11/07/2019.
//  Copyright © 2019 Zachary Waldowski and Pandamonia LLC. All rights reserved.
//

#import "BKLock.h"


@interface BKLock ()

@property (nonatomic, strong) dispatch_semaphore_t lock;

@end


@implementation BKLock


- (instancetype)init
{
	if (self = [super init])
	{
		_lock = dispatch_semaphore_create(1);
	}
	
	return self;
}


- (void)exec:(void(^)(void))block
{
	dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
	block();
	dispatch_semaphore_signal(self.lock);
}

@end
