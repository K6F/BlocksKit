//
//  BKConcurrentEnumerator.m
//  BlocksKit
//
//  Created by Andrew Romanov on 09/07/2019.
//  Copyright © 2019 Zachary Waldowski and Pandamonia LLC. All rights reserved.
//

#import "BKConcurrentEnumerator.h"


@interface BKConcurrentEnumerator ()

@property (nonatomic, strong) NSEnumerator* sourceEnumerator;
@property (nonatomic, strong) dispatch_semaphore_t semathore;

@end


@interface BKConcurrentEnumerator (Private)

- (void)_execSyncCode:(void(^)(void))block;

@end


@implementation BKConcurrentEnumerator


- (instancetype)initWithEnumerator:(NSEnumerator *)enumerator
{
	if (self = [super init])
	{
		_sourceEnumerator = enumerator;
		_semathore = dispatch_semaphore_create(1);
	}
	
	return self;
}


- (nullable id)nextObject
{
	__block id obj = nil;
	[self _execSyncCode:^{
		obj = [self.sourceEnumerator nextObject];
	}];
	
	return obj;
}


- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained _Nullable [_Nonnull])buffer count:(NSUInteger)len
{
	__block NSUInteger count = 0;
	[self _execSyncCode:^{
		count = [self.sourceEnumerator countByEnumeratingWithState:state
																											 objects:buffer
																												 count:len];
	}];
	return count;
}


- (NSArray *)allObjects
{
	__block NSArray* allObjs = @[];
	[self _execSyncCode:^{
		allObjs = [self.sourceEnumerator allObjects];
	}];
	
	return allObjs;
}

@end


#pragma mark -
@implementation BKConcurrentEnumerator (Private)

- (void)_execSyncCode:(void(^)(void))block
{
	dispatch_semaphore_wait(_semathore, DISPATCH_TIME_FOREVER);
	block();
	dispatch_semaphore_signal(_semathore);
}

@end
