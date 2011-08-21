#import <Cocoa/Cocoa.h>
#import "Game.h"

@class Item;

@interface Game (Items)

// add or remove item to the game (when it's next safe to do so)
- (void)addItem:(Item *)item;
- (void)removeItem:(Item *)item;

// actually add and remove the items that are queued
// (called when the items aren't being enumerated)
- (void)addAndRemoveItems;

@end
