//
//  NSUserDefaultsTest.m
//  BlocksKit
//
//  Created by Andrew Romanov on 05/03/2018.
//  2018 Zachary Waldowski and Pandamonia LLC
//

#import <XCTest/XCTest.h>
#import "NSUserDefaults+BlocksKit.h"


@interface NSUserDefaultsTest : XCTestCase

@property (nonatomic, strong) NSUserDefaults* defaults;

@end


@implementation NSUserDefaultsTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	_defaults = [[NSUserDefaults alloc] initWithSuiteName:@"test.blocksKit.suite"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
	
	NSDictionary* representation = [_defaults dictionaryRepresentation];
	[representation enumerateKeysAndObjectsUsingBlock:^(NSString* _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
		[self.defaults removeObjectForKey:key];
	}];
	[_defaults removeSuiteNamed:@"test.blocksKit.suite"];
}


- (void)testObject
{
	NSString* key = @"key";
	
	NSNumber* defaultValue = @(13);
	id(^getter)(void) = ^{return defaultValue;};
	
	NSNumber* getted = [_defaults bk_objectForKey:key
															withDefaultGetter:getter];
	XCTAssertEqualObjects(getted, defaultValue);
	
	NSNumber* setted = @(1);
	[_defaults setObject:setted forKey:key];
	getted = [_defaults bk_objectForKey:key
										withDefaultGetter:getter];
	XCTAssertNotEqualObjects(getted, defaultValue);
	XCTAssertEqualObjects(setted, getted);
}


- (void)testString
{
	NSString* key = @"key";
	
	NSString* defaultValue = @"default";
	NSString*(^getter)(void) = ^{return defaultValue;};
	
	NSString* getted = [_defaults bk_stringForKey:key withDefaultGetter:getter];
	XCTAssertEqualObjects(getted, defaultValue);
	
	NSString* setted = @"setted";
	[_defaults setObject:setted forKey:key];
	getted = [_defaults bk_stringForKey:key withDefaultGetter:getter];
	XCTAssertNotEqualObjects(getted, defaultValue);
	XCTAssertEqualObjects(setted, getted);
}


- (void)testArray
{
	NSString* key = @"key";
	
	NSArray* defaultValue = @[@"def", @(13)];
	NSArray*(^getter)(void) = ^{return defaultValue;};
	
	NSArray* getted = [_defaults bk_arrayForKey:key withDefaultGetter:getter];
	XCTAssertEqualObjects(getted, defaultValue);
	
	NSArray* setted = @[@"setted", @(1)];
	[_defaults setObject:setted forKey:key];
	getted = [_defaults bk_arrayForKey:key
									 withDefaultGetter:getter];
	XCTAssertNotEqualObjects(getted, defaultValue);
	XCTAssertEqualObjects(setted, getted);
}


- (void)testDictionary
{
	NSString* key = @"key";
	
	NSDictionary<NSString *, id>* defaultValue = @{@"def": @(13)};
	NSDictionary*(^getter)(void) = ^{return defaultValue;};
	
	NSDictionary<NSString *, id>* getted = [_defaults bk_dictionaryForKey:key withDefaultGetter:getter];
	XCTAssertEqualObjects(getted, defaultValue);
	
	NSDictionary<NSString *, id>* setted = @{@"setted": @(1)};
	[_defaults setObject:setted forKey:key];
	getted = [_defaults bk_dictionaryForKey:key withDefaultGetter:getter];
	XCTAssertNotEqualObjects(getted, defaultValue);
	XCTAssertEqualObjects(setted, getted);
}


- (void)testData
{
	NSString* key = @"key";
	
	char defaultBytes[4] = {1, 2, 3, 4};
	NSData* defaultValue = [NSData dataWithBytes:defaultBytes length:4];
	NSData*(^getter)(void) = ^{return defaultValue;};
	
	NSData* getted = [_defaults bk_dataForKey:key withDefaultGetter:getter];
	XCTAssertEqualObjects(getted, defaultValue);
	
	char settedBytes[4] = {1, 1, 1, 1};
	NSData* setted = [NSData dataWithBytes:settedBytes length:4];
	[_defaults setObject:setted forKey:key];
	getted = [_defaults bk_dataForKey:key withDefaultGetter:getter];
	XCTAssertNotEqualObjects(getted, defaultValue);
	XCTAssertEqualObjects(setted, getted);
}


- (void)testStringArray
{
	NSString* key = @"key";
	
	NSArray<NSString*>* defaultValue = @[@"def1", @"def2"];
	NSArray<NSString*>*(^getter)(void) = ^{return defaultValue;};
	
	NSArray<NSString*>* getted = [_defaults bk_stringArrayForKey:key withDefaultGetter:getter];
	XCTAssertEqualObjects(getted, defaultValue);
	
	NSArray<NSString*>* setted = @[@"setted1", @"setted2", @"setted3"];
	[_defaults setObject:setted forKey:key];
	getted = [_defaults bk_stringArrayForKey:key withDefaultGetter:getter];
	XCTAssertNotEqualObjects(getted, defaultValue);
	XCTAssertEqualObjects(setted, getted);
}


- (void)testInteger
{
	NSString* key = @"key";
	
	NSInteger defaultValue = 13;
	NSInteger(^getter)(void) = ^{return defaultValue;};
	
	NSInteger getted = [_defaults bk_integerForKey:key withDefaultGetter:getter];
	XCTAssertEqual(getted, defaultValue);
	
	NSInteger setted = 1;
	[_defaults setInteger:setted forKey:key];
	getted = [_defaults bk_integerForKey:key withDefaultGetter:getter];
	XCTAssertNotEqual(getted, defaultValue);
	XCTAssertEqual(setted, getted);
}


- (void)testFloat
{
	NSString* key = @"key";
	
	float defaultValue = 13.0;
	float(^getter)(void) = ^{return defaultValue;};
	
	float getted = [_defaults bk_floatForKey:key withDefaultGetter:getter];
	XCTAssertEqual(getted, defaultValue);
	
	float setted = 1;
	[_defaults setFloat:setted forKey:key];
	getted = [_defaults bk_floatForKey:key withDefaultGetter:getter];
	XCTAssertNotEqual(getted, defaultValue);
	XCTAssertEqual(setted, getted);
}


- (void)testDouble
{
	NSString* key = @"key";
	
	double defaultValue = 13.0;
	double(^getter)(void) = ^{return defaultValue;};
	
	double getted = [_defaults bk_doubleForKey:key withDefaultGetter:getter];
	XCTAssertEqual(getted, defaultValue);
	
	double setted = 1;
	[_defaults setDouble:setted forKey:key];
	getted = [_defaults bk_doubleForKey:key withDefaultGetter:getter];
	XCTAssertNotEqual(getted, defaultValue);
	XCTAssertEqual(setted, getted);
}


- (void)testBool
{
	NSString* key = @"key";
	
	BOOL defaultValue = YES;
	BOOL(^getter)(void) = ^{return defaultValue;};
	
	BOOL getted = [_defaults bk_boolForKey:key withDefaultGetter:getter];
	XCTAssertEqual(getted, defaultValue);
	
	BOOL setted = NO;
	[_defaults setBool:setted forKey:key];
	getted = [_defaults bk_boolForKey:key withDefaultGetter:getter];
	XCTAssertNotEqual(getted, defaultValue);
	XCTAssertEqual(setted, getted);
}


- (void)testURL
{
	NSString* key = @"key";
	
	NSURL* defaultValue = [NSURL URLWithString:@"http://default.example.com"];
	NSURL*(^getter)(void) = ^{return defaultValue;};
	
	NSURL* getted = [_defaults bk_URLForKey:key withDefaultGetter:getter];
	XCTAssertEqualObjects(getted, defaultValue);
	
	NSURL* setted = [NSURL URLWithString:@"http://setted.example.com"];
	[_defaults setURL:setted forKey:key];
	getted = [_defaults bk_URLForKey:key withDefaultGetter:getter];
	XCTAssertNotEqualObjects(getted, defaultValue);
	XCTAssertEqualObjects(setted, getted);
}

@end
