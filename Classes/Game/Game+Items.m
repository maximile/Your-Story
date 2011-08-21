#import "Game+Items.h"


@implementation Game (Items)

- (void)addItem:(Item *)item {
	if (![itemsToAdd containsObject:item])
		[itemsToAdd addObject:item];
}

- (void)removeItem:(Item *)item {
	if (![itemsToRemove containsObject:item])
		[itemsToRemove addObject:item];
}

- (void)addAndRemoveItems {
	while (itemsToRemove.count > 0) {
		NSArray *tempItemsToRemove = [itemsToRemove copy];
		itemsToRemove = [NSMutableArray array];
		for (Item *item in tempItemsToRemove) {
			[item removeFromSpace:space];
			[items removeObject:item];
		}
	}
	
	while (itemsToAdd.count > 0) {
		NSArray *tempItemsToAdd = [itemsToAdd copy];
		itemsToAdd = [NSMutableArray array];
		for (Item *item in tempItemsToAdd) {
			[items addObject:item];
			[item addToSpace:space];
		}
	}
}


@end
