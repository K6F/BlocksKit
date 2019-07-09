//
//  BKConcurrentArrayTest.m
//  BlocksKit
//
//  Created by Andrew Romanov on 09/07/2019.
//  Copyright © 2019 Zachary Waldowski and Pandamonia LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BKConcurrentArray.h"


@interface BKConcurrentArrayTest : XCTestCase

@property (nonatomic) NSInteger total;
@property (nonatomic, strong) dispatch_semaphore_t lock;

@end



@interface BKConcurrentArrayTest (private)

- (void)_execInLockMode:(void(^)(void))block;

@end


@implementation BKConcurrentArrayTest {
	BKConcurrentArray* _subject;
	BKConcurrentArray* _integers;
	BKConcurrentArray* _floats;
}

- (void)setUp {
	_subject = [[BKConcurrentArray alloc] initWithArray:@[ @"1", @"22", @"333" ]];
	_integers = [[BKConcurrentArray alloc] initWithArray:@[@(1), @(2), @(3)]];
	_floats = [[BKConcurrentArray alloc] initWithArray:@[@(.1), @(.2), @(.3)]];
	_total = 0;
	self.lock = dispatch_semaphore_create(1);
}

- (void)tearDown {
	_subject = nil;
}

- (void)testEach {
	void (^senderBlock)(NSString *) = ^(NSString *sender) {
		[self _execInLockMode:^{
			self.total += [sender length];
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
	
	// bk_match: is functionally identical to bk_select:, but will stop and return on the first match
	XCTAssertEqual(found, @"22", @"matched object is %@", found);
}

- (void)testNotMatch {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		BOOL match = ([obj intValue] == 4444) ? YES : NO;
		return match;
	};
	id found = [_subject bk_match:validationBlock];
	
	// @return Returns the object if found, `nil` otherwise.
	XCTAssertNil(found, @"no matched object");
}

- (void)testSelect {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		[self _execInLockMode:^{
			self.total += [obj length];
		}];
		BOOL match = ([obj intValue] < 300) ? YES : NO;
		return match;
	};
	NSArray *found = [_subject bk_select:validationBlock];
	
	XCTAssertEqual(_total, (NSInteger)6, @"total length of \"122333\" is %ld", (long)_total);
	NSArray *target = @[ @"1", @"22" ];
	XCTAssertEqualObjects(found, target, @"selected items are %@", found);
}

- (void)testSelectedNone {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		[self _execInLockMode:^{
			self.total += [obj length];
		}];
		BOOL match = ([obj intValue] > 400) ? YES : NO;
		return match;
	};
	NSArray *found = [_subject bk_select:validationBlock];
	
	XCTAssertEqual(_total, (NSInteger)6, @"total length of \"122333\" is %ld", (long)_total);
	XCTAssertTrue(found.count == 0, @"no item is selected");
}

- (void)testReject {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		[self _execInLockMode:^{
			self.total += [obj length];
		}];
		BOOL match = ([obj intValue] > 300) ? YES : NO;
		return match;
	};
	NSArray *left = [_subject bk_reject:validationBlock];
	
	XCTAssertEqual(_total, (NSInteger)6, @"total length of \"122333\" is %ld", (long)_total);
	NSArray *target = @[ @"1", @"22" ];
	XCTAssertEqualObjects(left, target, @"not rejected items are %@", left);
}

- (void)testRejectedAll {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		[self _execInLockMode:^{
			self.total += [obj length];
		}];
		
		BOOL match = ([obj intValue] < 400) ? YES : NO;
		return match;
	};
	NSArray *left = [_subject bk_reject:validationBlock];
	
	XCTAssertEqual(_total, (NSInteger)6, @"total length of \"122333\" is %ld", (long)_total);
	XCTAssertTrue(left.count == 0, @"all items are rejected");
}

- (void)testMap {
	id(^transformBlock)(id) = ^(NSString *obj) {
		[self _execInLockMode:^{
			self.total += [obj length];
		}];
		return [obj substringToIndex:1];
	};
	NSArray *transformed = [_subject bk_map:transformBlock];
	
	XCTAssertEqual(_total, (NSInteger)6, @"total length of \"122333\" is %ld", (long)_total);
	NSArray *target = @[ @"1", @"2", @"3" ];
	[target enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		XCTAssertTrue([transformed containsObject:obj]);
	}];
}

- (void)testCompact {
	BKConcurrentArray *mixed = [[BKConcurrentArray alloc] initWithArray:@[@"foo", @2, @"bar", @YES]];
	
	NSArray *transformed = [mixed bk_compact:^id(id obj) {
		[self _execInLockMode:^{
			self.total += 1;
		}];
		
		if([obj isKindOfClass:[NSString class]])
		{
			NSString *string = obj;
			return [string stringByAppendingString:@".png"];
		}
		
		return nil;
	}];
	
	XCTAssertEqual(self.total, (NSUInteger)4, @"iterated %i times", (int) self.total);
	NSArray *target = @[ @"foo.png", @"bar.png" ];
	XCTAssertTrue([transformed containsObject:target[0]]);
	XCTAssertTrue([transformed containsObject:target[1]]);
}


- (void)testAny {
	// Check if array has element with prefix 1
	BOOL(^existsBlockTrue)(id) = ^(id obj) {
		return [obj hasPrefix:@"1"];
	};
	
	BOOL(^existsBlockFalse)(id) = ^(id obj) {
		return [obj hasPrefix:@"4"];
	};
	
	BOOL letterExists = [_subject bk_any:existsBlockTrue];
	XCTAssertTrue(letterExists, @"letter is not in array");
	
	BOOL letterDoesNotExist = [_subject bk_any:existsBlockFalse];
	XCTAssertFalse(letterDoesNotExist, @"letter is in array");
}

- (void)testAll {
	BKConcurrentArray *names = [[BKConcurrentArray alloc] initWithArray:@[ @"John", @"Joe", @"Jon", @"Jester" ]];
	BKConcurrentArray *names2 = [[BKConcurrentArray alloc] initWithArray:@[ @"John", @"Joe", @"Jon", @"Mary" ]];
	
	// Check if array has element with prefix 1
	BOOL(^nameStartsWithJ)(id) = ^(id obj) {
		return [obj hasPrefix:@"J"];
	};
	
	BOOL allNamesStartWithJ = [names bk_all:nameStartsWithJ];
	XCTAssertTrue(allNamesStartWithJ, @"all names do not start with J in array");
	
	BOOL allNamesDoNotStartWithJ = [names2 bk_all:nameStartsWithJ];
	XCTAssertFalse(allNamesDoNotStartWithJ, @"all names do start with J in array");
}

- (void)testNone {
	BKConcurrentArray *names = [[BKConcurrentArray alloc] initWithArray:@[ @"John", @"Joe", @"Jon", @"Jester" ]];
	BKConcurrentArray *names2 = [[BKConcurrentArray alloc] initWithArray:@[ @"John", @"Joe", @"Jon", @"Mary" ]];
	
	// Check if array has element with prefix 1
	BOOL(^nameStartsWithM)(id) = ^(id obj) {
		return [obj hasPrefix:@"M"];
	};
	
	BOOL noNamesStartWithM = [names bk_none:nameStartsWithM];
	XCTAssertTrue(noNamesStartWithM, @"some names start with M in array");
	
	BOOL someNamesStartWithM = [names2 bk_none:nameStartsWithM];
	XCTAssertFalse(someNamesStartWithM, @"no names start with M in array");
}

- (void)testCorresponds {
	BKConcurrentArray* numbers = [[BKConcurrentArray alloc] initWithArray:@[ @(1), @(2), @(3) ]];
	NSArray* letters = @[ @"1", @"2", @"3" ];
	BOOL doesCorrespond = [numbers bk_corresponds:letters withBlock:^(id number, id letter) {
		return [[number stringValue] isEqualToString:letter];
	}];
	XCTAssertTrue(doesCorrespond, @"1,2,3 does not correspond to \"1\",\"2\",\"3\"");
	
}


- (void)testMin {
	BKConcurrentArray* numbers1 = [[BKConcurrentArray alloc] initWithArray:@[@(1), @(2), @(3)]];
	NSNumber* min1 = [numbers1 bk_min:^(NSNumber* num){
		return [num doubleValue];
	}];
	XCTAssert([min1 isEqual:@(1)], @"min should be 1");
	
	BKConcurrentArray* numbers2 = [[BKConcurrentArray alloc] initWithArray:@[@(3), @(2), @(1)]];
	NSNumber* min2 = [numbers2 bk_min:^(NSNumber* num){
		return [num doubleValue];
	}];
	XCTAssert([min2 isEqual:@(1)], @"min should be 1");
}


- (void)testMax {
	BKConcurrentArray* numbers1 = [[BKConcurrentArray alloc] initWithArray:@[@(1), @(2), @(3)]];
	NSNumber* min1 = [numbers1 bk_max:^(NSNumber* num){
		return [num doubleValue];
	}];
	XCTAssert([min1 isEqual:@(3)], @"min should be 1");
	
	BKConcurrentArray* numbers2 = [[BKConcurrentArray alloc] initWithArray:@[@(3), @(2), @(1)]];
	NSNumber* min2 = [numbers2 bk_max:^(NSNumber* num){
		return [num doubleValue];
	}];
	XCTAssert([min2 isEqual:@(3)], @"min should be 1");
}


- (void)testCreateConcurrent{
	NSArray* array = @[@"1", @"2", @"3", @(4)];
	BKConcurrentArray* cArray = [array bk_concurrent];
	XCTAssertNotNil(cArray);
	XCTAssertTrue(cArray.count == array.count);
}


@end


@implementation BKConcurrentArrayTest (private)

- (void)_execInLockMode:(void(^)(void))block
{
	dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
	block();
	dispatch_semaphore_signal(self.lock);
}

@end
