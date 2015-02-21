//
//  MatchingLayerController.m
//  VocabRPG
//
//  Created by Junjia He on 2/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "MatchingLayerController.h"
#import "MatchingBlock.h"
#import "MemorizationModel.h"

static double const BLOCK_X_MARGIN = 0.2;
static int WORD_NUM = 4;

@implementation MatchingLayerController {
  MemorizationModel *_model;
  NSMutableArray *_leftBlocks, *_rightBlocks;
  int _blockSize;

  NSMutableArray *correctWordMap;
  int _pressedRecords[2];
}

- (id)init {
  _model = [MemorizationModel new];
  _pressedRecords[0] = -1;
  _pressedRecords[1] = -1;
  return self;
}

- (NSArray *)generateMatchingBlock {
  // get next 4 word-meaning pairs
  NSMutableArray *words = [NSMutableArray new],
                 *meanings = [NSMutableArray new];
  for (int i = 0; i < WORD_NUM; ++i) {
    NSArray *wordPair = [[_model getNextPair] componentsSeparatedByString:@":"];
    [words addObject:[wordPair objectAtIndex:0]];
    [meanings addObject:[wordPair objectAtIndex:1]];
  }
  correctWordMap = [NSMutableArray arrayWithObjects:@0, @1, @2, @3, nil];
  [MatchingLayerController shuffle:correctWordMap];
  NSLog(@"shuffled array:%@", correctWordMap);

  // init blocks
  _leftBlocks = [NSMutableArray arrayWithCapacity:4];
  _rightBlocks = [NSMutableArray arrayWithCapacity:4];
  _blockSize = 4;

  double block_yspacing = 0.2f, block_ystart = 0.2;

  for (int i = 0; i < _blockSize; ++i) {
    MatchingBlock *left =
        (MatchingBlock *)[CCBReader load:@"MatchingBlock" owner:self];
    left.positionType = CCPositionTypeNormalized;
    left.position = ccp(BLOCK_X_MARGIN, block_ystart + i * block_yspacing);
    left.buttonName = [NSString stringWithFormat:@"left_%d", i];
    left.buttonTitle = [words objectAtIndex:i];
    [_leftBlocks addObject:left];

    MatchingBlock *right =
        (MatchingBlock *)[CCBReader load:@"MatchingBlock" owner:self];
    right.positionType = CCPositionTypeNormalized;
    right.position = ccp(1 - BLOCK_X_MARGIN, block_ystart + i * block_yspacing);
    right.buttonName = [NSString stringWithFormat:@"right_%d", i];
    right.buttonTitle = [meanings
        objectAtIndex:[[correctWordMap objectAtIndex:i] unsignedIntegerValue]];
    [_rightBlocks addObject:right];
  }

  return [_leftBlocks arrayByAddingObjectsFromArray:_rightBlocks];
}

- (void)blockPressed:(id)sender {
  NSArray *parts = [((CCButton *)sender).name componentsSeparatedByString:@"_"];
  NSString *side = [parts objectAtIndex:0];
  int buttonIndex = [[parts objectAtIndex:1] intValue];

  int column = [side isEqualToString:@"left"] ? 0 : 1;
  _pressedRecords[column] = buttonIndex;

  // check answer if both column pressed
  if (_pressedRecords[0] > -1 && _pressedRecords[1] > -1) {
    if ([[correctWordMap objectAtIndex:_pressedRecords[0]] intValue] ==
        _pressedRecords[1]) {
      NSLog(@"Good");
    } else {
      NSLog(@"Wrong");
    }
    // reset pressed records
    _pressedRecords[0] = -1;
    _pressedRecords[1] = -1;
  }
}

+ (void)shuffle:(NSMutableArray *)array {
  NSUInteger count = [array count];
  for (NSUInteger i = 0; i < count; ++i) {
    NSInteger remainingCount = count - i;
    NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t)remainingCount);
    [array exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
  }
}

@end
