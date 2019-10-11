//
//  NSNumber+BlocksKit.m
//  BlocksKit
//

#import "NSNumber+BlocksKit.h"

@implementation NSNumber (BlocksKit)

- (void)bk_times:(void (^)(void))block
{
  NSParameterAssert(block != nil);

  for (NSInteger idx = 0 ; idx < self.integerValue ; ++idx ) {
    block();
  }
}


- (void)bk_concurrently:(void(^)(void))block
{
	if (self.integerValue >= 0)
	{
		NSIndexSet* indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.integerValue)];
		[indexes enumerateIndexesWithOptions:NSEnumerationConcurrent
															usingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
																block();
															}];
	}
}


- (void)bk_enumerate:(void(^)(NSInteger))block
{
	NSParameterAssert(block != nil);

	 for (NSInteger idx = 0 ; idx < self.integerValue ; ++idx ) {
		 block(idx);
	 }
}


@end
