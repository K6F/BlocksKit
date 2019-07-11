//
//  BKConcurrentIndexSetTest.m
//  BlocksKit
//
//  Created by Andrew Romanov on 10/07/2019.
//  Copyright © 2019 Zachary Waldowski and Pandamonia LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BKConcurrentIndexSet.h"


@interface BKConcurrentIndexSetTest : XCTestCase

@end


@interface BKConcurrentIndexSetTest (Private)

- (BOOL)_checkProcessedCharacters:(NSCharacterSet*)processedString withDestinationCharacters:(NSCharacterSet*)destinationprocessed;

@end


@implementation BKConcurrentIndexSetTest{
	BKConcurrentIndexSet *_subject;
	NSMutableArray  *_target;
	NSCharacterSet* _allIndexesCharacters;
}

- (void)setUp {
	_target = [@[@"0", @"0", @"0", @"0"] mutableCopy];
	_subject = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)].bk_concurrent;
	_allIndexesCharacters = [NSCharacterSet characterSetWithCharactersInString:@"123"];
}

- (void)testEach {
	NSMutableCharacterSet *processed = [[NSMutableCharacterSet alloc] init];
	dispatch_semaphore_t lock = dispatch_semaphore_create(1);
	void(^indexBlock)(NSUInteger) = ^(NSUInteger index) {
		dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
		NSString* character = [NSString stringWithFormat:@"%lu", (unsigned long)index];
		[processed addCharactersInString:character];
		self->_target[index] = character;
		dispatch_semaphore_signal(lock);
	};
	[_subject bk_each:indexBlock];
	XCTAssertTrue([self _checkProcessedCharacters:processed withDestinationCharacters:self->_allIndexesCharacters]);
	NSArray<NSString*> *target = @[ @"0", @"1", @"2", @"3" ];
	XCTAssertEqualObjects(target[0], _target[0]);
	[target enumerateObjectsUsingBlock:^(NSString* _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		XCTAssertTrue([self->_target containsObject:obj]);
	}];
}

- (void)testMatch {
	dispatch_semaphore_t lock = dispatch_semaphore_create(1);
	BOOL(^indexValidationBlock)(NSUInteger) = ^(NSUInteger index) {
		BOOL match = NO;
		if (index%2 == 0 ) {
			dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
			self->_target[index] = [NSString stringWithFormat:@"%lu", (unsigned long)index];
			dispatch_semaphore_signal(lock);
			match = YES;
		}
		return match;
	};
	NSUInteger found = [_subject bk_match:indexValidationBlock];
	//we can make this check because we have only one index with mod of 2 == 0
	XCTAssertEqualObjects(_target[found], @"2", @"the target array becomes %@", _target);
}

- (void)testNotMatch {
	NSMutableCharacterSet *processed = [[NSMutableCharacterSet alloc] init];
	dispatch_semaphore_t lock = dispatch_semaphore_create(1);
	BOOL(^indexValidationBlock)(NSUInteger) = ^(NSUInteger index) {
		dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
		[processed addCharactersInString:[NSString stringWithFormat:@"%lu", (unsigned long)index]];
		dispatch_semaphore_signal(lock);
		BOOL match = index > 4 ? YES : NO;
		return match;
	};
	NSUInteger found = [_subject bk_match:indexValidationBlock];
	[self _checkProcessedCharacters:processed withDestinationCharacters:self->_allIndexesCharacters];
	XCTAssertEqual((NSUInteger)found, (NSUInteger)NSNotFound, @"no items are found");
}

- (void)testSelect {
	NSMutableCharacterSet *processed = [[NSMutableCharacterSet alloc] init];
	dispatch_semaphore_t lock = dispatch_semaphore_create(1);
	BOOL(^indexValidationBlock)(NSUInteger) = ^(NSUInteger index) {
		dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
		[processed addCharactersInString:[NSString stringWithFormat:@"%lu", (unsigned long)index]];
		dispatch_semaphore_signal(lock);
		BOOL match = index < 3 ? YES : NO;
		return match;
	};
	NSIndexSet *found = [_subject bk_select:indexValidationBlock];
	[self _checkProcessedCharacters:processed withDestinationCharacters:self->_allIndexesCharacters];
	NSIndexSet *target = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1,2)];
	XCTAssertEqualObjects(found, target, @"the selected index set is %@", found);
}

- (void)testSelectedNone {
	NSMutableCharacterSet *processed = [[NSMutableCharacterSet alloc] init];
	dispatch_semaphore_t lock = dispatch_semaphore_create(1);
	BOOL(^indexValidationBlock)(NSUInteger) = ^(NSUInteger index) {
		dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
		[processed addCharactersInString:[NSString stringWithFormat:@"%lu", (unsigned long)index]];
		dispatch_semaphore_signal(lock);
		BOOL match = index == 0 ? YES : NO;
		return match;
	};
	NSIndexSet *found = [_subject bk_select:indexValidationBlock];
	[self _checkProcessedCharacters:processed withDestinationCharacters:self->_allIndexesCharacters];
	XCTAssertNotNil(found, @"result should not be nil");
	XCTAssertEqual(found.count, (NSUInteger)0, @"no index found");
}

- (void)testReject {
	NSMutableCharacterSet *processed = [[NSMutableCharacterSet alloc] init];
	dispatch_semaphore_t lock = dispatch_semaphore_create(1);
	BOOL(^indexValidationBlock)(NSUInteger) = ^(NSUInteger index) {
		dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
		[processed addCharactersInString:[NSString stringWithFormat:@"%lu", (unsigned long)index]];
		dispatch_semaphore_signal(lock);
		BOOL match = [self->_target[index] isEqual:@"0"] ? YES : NO;
		return match;
	};
	NSIndexSet *found = [_subject bk_reject:indexValidationBlock];
	[self _checkProcessedCharacters:processed withDestinationCharacters:self->_allIndexesCharacters];
	XCTAssertEqual(found.count, (NSUInteger)0, @"all indexes are rejected");
}

- (void)testRejectedNone {
	NSMutableCharacterSet *processed = [[NSMutableCharacterSet alloc] init];
	dispatch_semaphore_t lock = dispatch_semaphore_create(1);
	BOOL(^indexValidationBlock)(NSUInteger) = ^(NSUInteger index) {
		dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
		[processed addCharactersInString:[NSString stringWithFormat:@"%lu", (unsigned long)index]];
		dispatch_semaphore_signal(lock);
		BOOL match = [self->_target[index] isEqual:@"0"] ? NO : YES;
		return match;
	};
	NSIndexSet *found = [_subject bk_reject:indexValidationBlock];
	[self _checkProcessedCharacters:processed withDestinationCharacters:self->_allIndexesCharacters];
	XCTAssertEqualObjects(found, _subject.indexes, @"all indexes that are not rejected %@", found);
}

- (void)testRejectedAll {
	BOOL(^indexValidationBlock)(NSUInteger) = ^(NSUInteger index) {
		return YES;
	};
	NSIndexSet *found = [_subject bk_reject:indexValidationBlock];
	XCTAssertNotNil(found);
	XCTAssertEqual(found.count, (NSUInteger)0, @"all indexes have been rejected");
}

- (void)testMap {
	NSMutableCharacterSet *processed = [[NSMutableCharacterSet alloc] init];
	dispatch_semaphore_t lock = dispatch_semaphore_create(1);
	NSUInteger(^indexValidationBlock)(NSUInteger) = ^(NSUInteger index) {
		dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
		[processed addCharactersInString:[NSString stringWithFormat:@"%lu", (unsigned long)index]];
		dispatch_semaphore_signal(lock);
		return index+self->_subject.count;
	};
	NSIndexSet *result = [_subject bk_map:indexValidationBlock];
	[self _checkProcessedCharacters:processed withDestinationCharacters:self->_allIndexesCharacters];
	NSIndexSet *target = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(4,3)];
	XCTAssertEqualObjects(result, target, @"the selected index set is %@", result);
}

- (void)testMapNone {
	BKConcurrentIndexSet *subject = [NSIndexSet new].bk_concurrent;
	NSUInteger(^indexValidationBlock)(NSUInteger) = ^(NSUInteger index) {
		return index;
	};
	NSIndexSet *result = [subject bk_map:indexValidationBlock];
	XCTAssertNotNil(result, @"result should not be nil");
	XCTAssertEqual(result.count, (NSUInteger)0, @"no index found");
}

- (void)testAny {
	__block NSMutableString *processed = [NSMutableString string];
	dispatch_semaphore_t lock = dispatch_semaphore_create(1);
	BOOL(^indexValidationBlock)(NSUInteger) = ^(NSUInteger index) {
		dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
		[processed appendFormat:@"%lu", (unsigned long)index];
		dispatch_semaphore_signal(lock);
		BOOL match = NO;
		if (index%2 == 0 ) {
			self->_target[index] = [NSString stringWithFormat:@"%lu", (unsigned long)index];
			match = YES;
		}
		return match;
	};
	BOOL didFind = [_subject bk_any:indexValidationBlock];
	XCTAssertTrue(processed.length <= 3);
	XCTAssertTrue(didFind, @"result found in target array");
}

@end


@implementation BKConcurrentIndexSetTest (Private)

- (BOOL)_checkProcessedCharacters:(NSCharacterSet*)processedString withDestinationCharacters:(NSCharacterSet*)destinationprocessed
{
	BOOL same = [processedString isEqual:destinationprocessed];
	return same;
}

@end
