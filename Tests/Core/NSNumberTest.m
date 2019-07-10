//
//  NSNumberTest.m
//  BlocksKit
//
//  Created by Andrew Romanov on 10/07/2019.
//  Copyright © 2019 Zachary Waldowski and Pandamonia LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
@import BlocksKit;

@interface NSNumberTest : XCTestCase


@end

@implementation NSNumberTest

- (void)testTimes {
	
	NSNumber* num = @(20);
	
	__block NSInteger count = 0;
	[num bk_times:^{
		count++;
	}];
	XCTAssert(count == 20);
}


- (void)testConcurrent {
	
	NSNumber* num = @(20);
	dispatch_semaphore_t lock = dispatch_semaphore_create(1);
	__block NSInteger count = 0;
	[num bk_concurrently:^{
		dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
		count++;
		dispatch_semaphore_signal(lock);
	}];
	XCTAssert(count == 20);
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
