//
//  BKTestGestureRecognizer.m
//  MobileBlocksKitTests
//
//  Created by Andrew Romanov on 14/01/2019.
//  Copyright © 2019 Zachary Waldowski and Pandamonia LLC. All rights reserved.
//

#import "BKTestGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import <objc/runtime.h>
#import <objc/message.h>


@implementation BKTestGestureRecognizer

- (void)forceGestureRecognitionForGestureRecogniser:(UIGestureRecognizer *)gestureRecogniser {
	Class gestureRecogniserTarget = NSClassFromString(@"UIGestureRecognizerTarget");
	Ivar targetIvar = class_getInstanceVariable(gestureRecogniserTarget, "_target");
	Ivar actionIvar = class_getInstanceVariable(gestureRecogniserTarget, "_action");
	
	for (id gestureRecogniserTarget in [gestureRecogniser valueForKey:@"targets"]) {
		id target = object_getIvar(gestureRecogniserTarget, targetIvar);
		SEL action = (__bridge void *)object_getIvar(gestureRecogniserTarget, actionIvar);
		void (*actionMethod)(id, SEL, id) = (void (*)(id, SEL, id))objc_msgSend;
		actionMethod(target, action, gestureRecogniser);
	}
}


- (instancetype)initWithTarget:(id)target action:(SEL)action
{
	if (self = [super initWithTarget:target action:action])
	{
		[self reset];
	}
	
	return self;
}


- (void)sendEventWithState:(UIGestureRecognizerState)state
{
	self.state = state;
	[self forceGestureRecognitionForGestureRecogniser:self];
}

@end
