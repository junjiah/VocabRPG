//
//  MatchingLayerController.m
//  VocabRPG
//
//  Created by Junjia He on 2/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "MatchingLayerController.h"
#import "MatchingBlock.h"

static double const BLOCK_X_MARGIN = 0.2;

@implementation MatchingLayerController {
  NSMutableArray *_leftBlocks, *_rightBlocks;
  int _blockSize;
}

- (NSArray *)generateMatchingBlock {

  // init blocks
  _leftBlocks = [NSMutableArray arrayWithCapacity:4];
  _rightBlocks = [NSMutableArray arrayWithCapacity:4];
  _blockSize = 4;
  
  double block_yspacing = 0.2f, block_ystart = 0.2;
  
  for (int i = 0; i < _blockSize; ++i) {
    MatchingBlock *left = (MatchingBlock *)[CCBReader load:@"MatchingBlock" owner:self];
    left.positionType = CCPositionTypeNormalized;
    left.position = ccp(BLOCK_X_MARGIN, block_ystart + i * block_yspacing);
    left.buttonName = [NSString stringWithFormat:@"left_%d", i];
    [_leftBlocks addObject:left];
    
    MatchingBlock *right = (MatchingBlock *)[CCBReader load:@"MatchingBlock" owner:self];
    right.positionType = CCPositionTypeNormalized;
    right.position = ccp(1 - BLOCK_X_MARGIN, block_ystart + i * block_yspacing);
    right.buttonName = [NSString stringWithFormat:@"right_%d", i];
    [_rightBlocks addObject:right];
  }
  
  return [_leftBlocks arrayByAddingObjectsFromArray:_rightBlocks];
}

- (void)blockPressed:(id)sender {
  NSArray *parts = [((CCButton *)sender).name componentsSeparatedByString:@"_"];
  NSString *side = [parts objectAtIndex:0];
  int buttonIndex = [[parts objectAtIndex:1] intValue];
  
  if ([side isEqualToString:@"left"]) {
    NSLog(@"pressed left button %d", buttonIndex);
  } else {
    NSLog(@"pressed right button %d", buttonIndex);
  }
}


@end
