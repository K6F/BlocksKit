//
//  BKLock.m
//  BlocksKit
//
//  Created by Andrew Romanov on 11/07/2019.
//  Copyright © 2019 Zachary Waldowski and Pandamonia LLC. All rights reserved.
//

#import "BKLock.h"


@interface BKLock ()

@property (nonatomic, strong) NSLock* lock;

@end


@implementation BKLock


- (instancetype)init
{
	if (self = [super init])
	{
		_lock = [[NSLock alloc] init];
	}
	
	return self;
}


- (void)exec:(void(^)(void))block
{
	[self.lock lock];
	block();
	[self.lock unlock];
}

@end
