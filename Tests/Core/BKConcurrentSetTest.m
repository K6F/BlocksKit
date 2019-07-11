//
//  BKConcurrentSetTest.m
//  BlocksKit
//
//  Created by Andrew Romanov on 11/07/2019.
//  Copyright © 2019 Zachary Waldowski and Pandamonia LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BKConcurrentSet.h"
#import "BKLock.h"

@interface BKConcurrentSetTest : XCTestCase

@end


@implementation BKConcurrentSetTest {
	BKConcurrentSet *_subject;
	NSInteger _total;
}

- (void)setUp {
	_subject = [NSSet setWithArray:@[ @"1", @"22", @"333" ]].bk_concurrent;
	_total = 0;
}

- (void)testEach {
	BKLock* sync = [[BKLock alloc] init];
	void(^senderBlock)(id) = ^(NSString *sender) {
		[sync exec:^{
			self->_total += [sender length];
		}];
	};
	[_subject bk_each:senderBlock];
	XCTAssertEqual(_total, (NSInteger)6, @"total length of \"122333\" is %ld", (long)_total);
}

- (void)testMatch {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		BOOL match = ([obj intValue] == 22) ? YES : NO;
		return match;
	};
	id found = [_subject bk_match:validationBlock];
	XCTAssertEqual(found, @"22",@"matched object is %@",found);
}

- (void)testNotMatch {
	BKLock* sync = [[BKLock alloc] init];
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		[sync exec:^{
			self->_total += [obj length];
		}];
		BOOL match = ([obj intValue] == 4444) ? YES : NO;
		return match;
	};
	id found = [_subject bk_match:validationBlock];
	XCTAssertEqual(_total,(NSInteger)6,@"total length of \"122333\" is %ld", (long)_total);
	XCTAssertNil(found,@"no matched object");
}

- (void)testSelect {
	BKLock* sync = [[BKLock alloc] init];
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		[sync exec:^{
			self->_total += [obj length];
		}];
		BOOL match = ([obj intValue] < 300) ? YES : NO;
		return match;
	};
	NSSet *found = [_subject bk_select:validationBlock];
	
	XCTAssertEqual(_total, (NSInteger)6, @"total length of \"122333\" is %ld", (long)_total);
	NSSet *target = [NSSet setWithArray:@[ @"1", @"22" ]];
	XCTAssertEqualObjects(found,target,@"selected items are %@",found);
}

- (void)testSelectedNone {
	BKLock* sync = [[BKLock alloc] init];
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		[sync exec:^{
			self->_total += [obj length];
		}];
		BOOL match = ([obj intValue] > 400) ? YES : NO;
		return match;
	};
	NSSet *found = [_subject bk_select:validationBlock];
	XCTAssertEqual(_total,(NSInteger)6, @"total length of \"122333\" is %ld", (long)_total);
	XCTAssertTrue(found.count == 0,@"no item is selected");
}

- (void)testReject {
	BKLock* sync = [[BKLock alloc] init];
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		[sync exec:^{
			self->_total += [obj length];
		}];
		BOOL match = ([obj intValue] > 300) ? YES : NO;
		return match;
	};
	NSSet *left = [_subject bk_reject:validationBlock];
	XCTAssertEqual(_total, (NSInteger)6, @"total length of \"122333\" is %ld", (long)_total);
	NSSet *target = [NSSet setWithArray:@[ @"1", @"22" ]];
	XCTAssertEqualObjects(left, target, @"not rejected items are %@",left);
}

- (void)testRejectedAll {
	BKLock* sync = [[BKLock alloc] init];
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		[sync exec:^{
			self->_total += [obj length];
		}];
		BOOL match = ([obj intValue] < 400) ? YES : NO;
		return match;
	};
	NSSet *left = [_subject bk_reject:validationBlock];
	XCTAssertEqual(_total,(NSInteger)6,@"total length of \"122333\" is %ld", (long)_total);
	XCTAssertTrue(left.count == 0,@"all items are rejected");
}

- (void)testMap {
	BKLock* sync = [[BKLock alloc] init];
	id(^transformBlock)(id) = ^(NSString *obj) {
		[sync exec:^{
			self->_total += [obj length];
		}];
		return [obj substringToIndex:1];
	};
	NSSet *transformed = [_subject bk_map:transformBlock];
	
	XCTAssertEqual(_total,(NSInteger)6,@"total length of \"122333\" is %ld", (long)_total);
	NSSet *target = [NSSet setWithArray:@[ @"1", @"2", @"3" ]];
	XCTAssertEqualObjects(transformed,target,@"transformed items are %@",transformed);
}


- (void)testAny {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		BOOL match = ([obj intValue] == 22) ? YES : NO;
		return match;
	};
	BOOL wasFound = [_subject bk_any:validationBlock];
	XCTAssertTrue(wasFound,@"matched object was found");
}

- (void)testAll {
	BKLock* sync = [[BKLock alloc] init];
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		[sync exec:^{
			self->_total += [obj length];
		}];
		BOOL match = ([obj intValue] < 444) ? YES : NO;
		return match;
	};
	
	BOOL allMatched = [_subject bk_all:validationBlock];
	XCTAssertEqual(_total,(NSInteger)6,@"total length of \"122333\" is %ld", (long)_total);
	XCTAssertTrue(allMatched, @"Not all values matched");
}

- (void)testNone {
	BKLock* sync = [[BKLock alloc] init];
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		[sync exec:^{
			self->_total += [obj length];
		}];
		BOOL match = ([obj intValue] < 1) ? YES : NO;
		return match;
	};
	
	BOOL noneMatched = [_subject bk_none:validationBlock];
	XCTAssertEqual(_total,(NSInteger)6,@"total length of \"122333\" is %ld", (long)_total);
	XCTAssertTrue(noneMatched, @"Some values matched");
}

- (void)testMin {
	NSSet* numbers = [NSSet setWithArray:@[@(1), @(2), @(3)]];
	NSNumber* min = [numbers.bk_concurrent bk_min:^(NSNumber* num){
		return [num doubleValue];
	}];
	XCTAssert([min isEqual:@(1)], @"min should be 1");
}


- (void)testMax {
	NSSet* numbers = [NSSet setWithArray:@[@(1), @(2), @(3)]];
	NSNumber* min = [numbers.bk_concurrent bk_max:^(NSNumber* num){
		return [num doubleValue];
	}];
	XCTAssert([min isEqual:@(3)], @"min should be 1");
}


@end
