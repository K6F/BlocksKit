//
//  BKLock.m
//  BlocksKit
//
//  Created by Andrew Romanov on 11/07/2019.
//  Copyright © 2019 Zachary Waldowski and Pandamonia LLC. All rights reserved.
//

#import "BKLock.h"
#import <mutex>


@interface BKLock ()
{
	std::mutex _mut;
}

@end


@implementation BKLock

- (void)exec:(void(^)(void))block
{
	std::lock_guard<std::mutex> quard(_mut);
	block();
}

@end
