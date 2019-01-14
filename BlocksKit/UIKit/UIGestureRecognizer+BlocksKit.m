//
//  UIGestureRecognizer+BlocksKit.m
//  BlocksKit
//

#import "UIGestureRecognizer+BlocksKit.h"
#import "NSObject+BKBlockExecution.h"
@import ObjectiveC.runtime;

static const void *BKGestureRecognizerBlockKey = &BKGestureRecognizerBlockKey;
static const void *BKGestureRecognizerDelayKey = &BKGestureRecognizerDelayKey;
static const void *BKGestureRecognizerShouldHandleActionKey = &BKGestureRecognizerShouldHandleActionKey;
static const void *BKGestureRecognizerTargetSetted = &BKGestureRecognizerTargetSetted;

@interface UIGestureRecognizer (BlocksKitInternal)

@property (nonatomic, setter = bk_setShouldHandleAction:) BOOL bk_shouldHandleAction;
@property (nonatomic, setter= bk_setTargetSetted:) BOOL bk_targetSetted;

- (void)bk_handleAction:(UIGestureRecognizer *)recognizer;

@end

@implementation UIGestureRecognizer (BlocksKit)

+ (instancetype)bk_recognizerWithHandler:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block delay:(NSTimeInterval)delay
{
	return [[[self class] alloc] bk_initWithHandler:block delay:delay];
}

- (instancetype)bk_initWithHandler:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block delay:(NSTimeInterval)delay
{
	self = [self initWithTarget:self action:@selector(bk_handleAction:)];
	if (!self) return nil;

	self.bk_targetSetted = YES;
	self.bk_handler = block;
	self.bk_handlerDelay = delay;

	return self;
}

+ (instancetype)bk_recognizerWithHandler:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block
{
	return [self bk_recognizerWithHandler:block delay:0.0];
}

- (instancetype)bk_initWithHandler:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block
{
	return (self = [self bk_initWithHandler:block delay:0.0]);
}

- (void)bk_handleAction:(UIGestureRecognizer *)recognizer
{
	void (^handler)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) = recognizer.bk_handler;
	if (!handler) return;
	
	NSTimeInterval delay = self.bk_handlerDelay;
	CGPoint location = [self locationInView:self.view];
	void (^block)(void) = ^{
		if (!self.bk_shouldHandleAction) return;
		handler(self, self.state, location);
	};

	self.bk_shouldHandleAction = YES;

    [NSObject bk_performAfterDelay:delay usingBlock:block];
}

- (void)bk_setHandler:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))handler
{
	objc_setAssociatedObject(self, BKGestureRecognizerBlockKey, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
	if (handler)
	{
		if (!self.bk_targetSetted)
		{
			[self addTarget:self action:@selector(bk_handleAction:)];
			self.bk_targetSetted = YES;
		}
	}
	else
	{
		if (self.bk_targetSetted)
		{
			[self removeTarget:self action:@selector(bk_handleAction:)];
			self.bk_targetSetted = NO;
		}
	}
}

- (void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))bk_handler
{
	return objc_getAssociatedObject(self, BKGestureRecognizerBlockKey);
}

- (void)bk_setHandlerDelay:(NSTimeInterval)delay
{
	NSNumber *delayValue = (delay != 0.0) ? @(delay) : nil;
	objc_setAssociatedObject(self, BKGestureRecognizerDelayKey, delayValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)bk_handlerDelay
{
	return [objc_getAssociatedObject(self, BKGestureRecognizerDelayKey) doubleValue];
}

- (void)bk_setShouldHandleAction:(BOOL)flag
{
	objc_setAssociatedObject(self, BKGestureRecognizerShouldHandleActionKey, @(flag), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)bk_shouldHandleAction
{
	return [objc_getAssociatedObject(self, BKGestureRecognizerShouldHandleActionKey) boolValue];
}

- (void)bk_cancel
{
	self.bk_shouldHandleAction = NO;
}


- (BOOL)bk_targetSetted
{
	BOOL setted = NO;
	NSNumber* settedValue = objc_getAssociatedObject(self, BKGestureRecognizerTargetSetted);
	if (settedValue)
	{
		setted = [settedValue boolValue];
	}
	
	return settedValue;
}


- (void)bk_setTargetSetted:(BOOL)bk_targetSetted
{
	objc_setAssociatedObject(self, BKGestureRecognizerTargetSetted, @(bk_targetSetted), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
