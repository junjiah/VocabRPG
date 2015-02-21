//
//  MatchingLayout.m
//  VocabRPG
//
//  Created by Junjia He on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "MatchingLayout.h"
#import "Block.h"

static int const BLOCK_X_MARGIN = 0.35;
static CCPositionType RIGHT_CORNER_POSITION = {
  CCPositionUnitNormalized, CCPositionUnitNormalized,
  CCPositionReferenceCornerBottomRight};
static CCPositionType LEFT_CORNER_POSITION = {
  CCPositionUnitNormalized, CCPositionUnitNormalized,
  CCPositionReferenceCornerBottomLeft};


@implementation MatchingLayout {
  NSMutableArray *_leftBlocks, *_rightBlocks;
  int _blockSize;
}

- (void)initialize {
  
  // init blocks
  _leftBlocks = [NSMutableArray arrayWithCapacity:4];
  _rightBlocks = [NSMutableArray arrayWithCapacity:4];
  _blockSize = 4;
  
  int block_yspacing = 0.2, block_ystart = 0.2;
  
  for (int i = 0; i < _blockSize; ++i) {
    Block *left = (Block *)[CCBReader load:@"Block"];
    left.positionType = LEFT_CORNER_POSITION;
    left.position = ccp(BLOCK_X_MARGIN, block_ystart + i * block_yspacing);
    [_leftBlocks addObject:left];
    [self addChild:left];
    
    Block *right = (Block *)[CCBReader load:@"Block"];
    right.positionType = RIGHT_CORNER_POSITION;
    right.position = ccp(BLOCK_X_MARGIN, block_ystart + i * block_yspacing);
    [_rightBlocks addObject:right];
    [self addChild:right];
  }
}


@end
