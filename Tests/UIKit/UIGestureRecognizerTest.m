//
//  UIGestureRecognizerTest.m
//  MobileBlocksKitTests
//
//  Created by Andrew Romanov on 14/01/2019.
//  Copyright © 2019 Zachary Waldowski and Pandamonia LLC. All rights reserved.
//

#import "UIGestureRecognizerTest.h"
#import "BKTestGestureRecognizer.h"


@implementation UIGestureRecognizerTest

- (void)testInitWithBlock
{
	__block BOOL called = NO;
	__block UIGestureRecognizerState  state = UIGestureRecognizerStatePossible;
	BKTestGestureRecognizer* recognizer = [[BKTestGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer * _Nonnull sender, UIGestureRecognizerState state, CGPoint location) {
		called = YES;
		state = sender.state;
		
		XCTAssertTrue(called);
		XCTAssertTrue(state == UIGestureRecognizerStateBegan);
	}];
	[recognizer sendEventWithState:UIGestureRecognizerStateBegan];
}


- (void)testSetBlock
{
	__block BOOL called = NO;
	__block UIGestureRecognizerState  state = UIGestureRecognizerStatePossible;
	BKTestGestureRecognizer* recognizer = [[BKTestGestureRecognizer alloc] initWithTarget:nil action:nil];
	recognizer.bk_handler = ^(UIGestureRecognizer * _Nonnull sender, UIGestureRecognizerState state, CGPoint location) {
		called = YES;
		state = sender.state;
		
		XCTAssertTrue(called);
		XCTAssertTrue(state == UIGestureRecognizerStateBegan);
	};
	[recognizer sendEventWithState:UIGestureRecognizerStateBegan];
}

@end
