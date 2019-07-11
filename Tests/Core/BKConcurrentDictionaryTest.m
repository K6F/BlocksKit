//
//  BKConcurrentDictionaryTest.m
//  BlocksKit
//
//  Created by Andrew Romanov on 11/07/2019.
//  Copyright © 2019 Zachary Waldowski and Pandamonia LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BKConcurrentDictionary.h"
#import "BKLock.h"


@interface BKConcurrentDictionaryTest : XCTestCase

@end

@implementation BKConcurrentDictionaryTest {
	BKConcurrentDictionary *_subject;
	NSInteger _total;
}

- (void)setUp {
	_subject = @{
							 @"1" : @(1),
							 @"2" : @(2),
							 @"3" : @(3),
							 }.bk_concurrent;
	_total = 0;
}

- (void)tearDown {
	_subject = nil;
}

- (void)testEach {
	BKLock* sync = [[BKLock alloc] init];
	void(^keyValueBlock)(id, id) = ^(id key,id value) {
		[sync exec:^{
			self->_total += [value intValue] + [key intValue];
		}];
	};
	
	[_subject bk_each:keyValueBlock];
	XCTAssertEqual(_total, (NSInteger)12, @"2*(1+2+3) = %ld", (long)_total);
}

- (void)testMatch {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		BOOL select = [value intValue] < 3 ? YES : NO;
		return select;
	};
	NSNumber *selected = [_subject bk_match:validationBlock];
	XCTAssertTrue([selected isEqual:@(1)] || [selected isEqual:@(2)], @"selected value is %@", selected);
}


- (void)testMatchNone {
	BKLock* sync = [[BKLock alloc] init];
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		[sync exec:^{
			self->_total += [value intValue] + [key intValue];
		}];
		BOOL select = [value intValue] > 3 ? YES : NO;
		return select;
	};
	NSDictionary *selected = [_subject bk_match:validationBlock];
	XCTAssertEqual(_total, (NSInteger)12, @"2*1 = %ld", (long)_total);
	XCTAssertNil(selected, @"must be nil object");
}


- (void)testSelect {
	BKLock* sync = [[BKLock alloc] init];
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		[sync exec:^{
			self->_total += [value intValue] + [key intValue];
		}];
		BOOL select = [value intValue] < 3 ? YES : NO;
		return select;
	};
	NSDictionary *selected = [_subject bk_select:validationBlock];
	XCTAssertEqual(_total, (NSInteger)12, @"2*(1+2+3) = %ld", (long)_total);
	NSDictionary *target = @{ @"1" : @(1), @"2" : @(2) };
	XCTAssertEqualObjects(selected, target, @"selected dictionary is %@", selected);
}


- (void)testSelectedNone {
	BKLock* sync = [[BKLock alloc] init];
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		[sync exec:^{
			self->_total += [value intValue] + [key intValue];
		}];
		BOOL select = [value intValue] > 4 ? YES : NO;
		return select;
	};
	NSDictionary *selected = [_subject bk_select:validationBlock];
	XCTAssertEqual(_total, (NSInteger)12, @"2*(1+2+3) = %ld", (long)_total);
	XCTAssertTrue(selected.count == 0, @"none item is selected");
}


- (void)testReject {
	BKLock* sync = [[BKLock alloc] init];
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		[sync exec:^{
			self->_total += [value intValue] + [key intValue];
		}];
		BOOL reject = [value intValue] < 3 ? YES : NO;
		return reject;
	};
	NSDictionary *rejected = [_subject bk_reject:validationBlock];
	XCTAssertEqual(_total, (NSInteger)12, @"2*(1+2+3) = %ld", (long)_total);
	NSDictionary *target = @{ @"3" : @(3) };
	XCTAssertEqualObjects(rejected, target, @"dictionary after rejection is %@", rejected);
}

- (void)testRejectedAll {
	BKLock* sync = [[BKLock alloc] init];
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		[sync exec:^{
			self->_total += [value intValue] + [key intValue];
		}];
		BOOL reject = [value intValue] < 4 ? YES : NO;
		return reject;
	};
	NSDictionary *rejected = [_subject bk_reject:validationBlock];
	XCTAssertEqual(_total, (NSInteger)12, @"2*(1+2+3) = %ld", (long)_total);
	XCTAssertTrue(rejected.count == 0, @"all items are selected");
}

- (void)testMap {
	BKLock* sync = [[BKLock alloc] init];
	id(^transformBlock)(id, id) = ^id(id key,id value) {
		__block NSInteger val;
		[sync exec:^{
			self->_total += [value intValue] + [key intValue];
			val = self->_total;
		}];
		return @(val);
	};
	NSDictionary *transformed = [_subject bk_map:transformBlock];
	XCTAssertEqual(_total, (NSInteger)12, @"2*(1+2+3) = %ld", (long)_total);
	NSDictionary *target = @{ @"1": @(2), @"2": @(6), @"3": @(12) };
	XCTAssertEqualObjects(transformed,target,@"transformed dictionary is %@",transformed);
}

- (void)testAny {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		BOOL select = [value intValue] < 3 ? YES : NO;
		return select;
	};
	BOOL isSelected = [_subject bk_any:validationBlock];
	XCTAssertEqual(isSelected, YES, @"found selected value is %i", isSelected);
}

- (void)testAll {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		BOOL select = [value intValue] < 4 ? YES : NO;
		return select;
	};
	BOOL allSelected = [_subject bk_all:validationBlock];
	XCTAssertTrue(allSelected, @"all values matched test");
}

- (void)testNone {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		BOOL select = [value intValue] < 2 ? YES : NO;
		return select;
	};
	BOOL noneSelected = [_subject bk_all:validationBlock];
	XCTAssertFalse(noneSelected, @"not all values matched test");
}

@end
