//
//  BKQueue.m
//  BlocksKit
//
//  Created by Andrew Romanov on 06/07/2017.
//  Copyright © 2017 Zachary Waldowski and Pandamonia LLC. All rights reserved.
//

#import "BKQueue.h"

@implementation BKQueue

+ (void)execSyncOnMainQueue:(void(^)(void))block
{
	if ([NSThread isMainThread])
	{
		block();
	}
	else
	{
		dispatch_sync(dispatch_get_main_queue(), block);
	}
}


+ (void)execAsyncOnMainQueue:(void(^)(void))block
{
	dispatch_async(dispatch_get_main_queue(), block);
}

@end
