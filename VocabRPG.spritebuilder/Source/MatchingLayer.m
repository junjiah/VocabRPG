//
//  MatchingLayout.m
//  VocabRPG
//
//  Created by Junjia He on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "MatchingLayer.h"
#import "MatchingLayerController.h"
#import "MatchingBlock.h"
#import "CombatScene.h"

static double const BLOCK_X_MARGIN = 0.2;

@implementation MatchingLayer {
  NSMutableArray *_leftBlocks, *_rightBlocks;
  int _blockSize;

  id<VocabularyDataSource> dataSource;
}

- (void)didLoadFromCCB {
  dataSource = [[MatchingLayerController alloc] initWithView:self];
  [self deployBlocks];
}

#pragma mark Place blocks

- (void)deployBlocks {
  NSDictionary *wordMeaningPairs = [dataSource generateWordMeaningPairs];
  NSMutableArray *words = [wordMeaningPairs objectForKey:@"words"],
                 *shuffledMeanings =
                     [wordMeaningPairs objectForKey:@"meanings"];
  // init blocks
  _leftBlocks = [NSMutableArray arrayWithCapacity:4];
  _rightBlocks = [NSMutableArray arrayWithCapacity:4];

  _blockSize = DISPLAY_WORD_NUM;

  double block_yspacing = 0.2f, block_ystart = 0.2;

  for (int i = 0; i < _blockSize; ++i) {
    MatchingBlock *left =
        (MatchingBlock *)[CCBReader load:@"MatchingBlock" owner:dataSource];
    left.positionType = CCPositionTypeNormalized;
    left.position = ccp(BLOCK_X_MARGIN, block_ystart + i * block_yspacing);
    left.buttonName = [NSString stringWithFormat:@"left_%d", i];
    left.buttonTitle = [words objectAtIndex:i];
    [_leftBlocks addObject:left];
    [self addChild:left];

    MatchingBlock *right =
        (MatchingBlock *)[CCBReader load:@"MatchingBlock" owner:dataSource];
    right.positionType = CCPositionTypeNormalized;
    right.position = ccp(1 - BLOCK_X_MARGIN, block_ystart + i * block_yspacing);
    right.buttonName = [NSString stringWithFormat:@"right_%d", i];
    right.buttonTitle = [shuffledMeanings objectAtIndex:i];
    [_rightBlocks addObject:right];
    [self addChild:right];
  }
}

- (void)reDeployBlocks {
  NSDictionary *wordMeaningPairs = [dataSource generateWordMeaningPairs];
  NSMutableArray *words = [wordMeaningPairs objectForKey:@"words"],
                 *shuffledMeanings =
                     [wordMeaningPairs objectForKey:@"meanings"];
  _blockSize = DISPLAY_WORD_NUM;
  // first clear all blocks
  for (int i = 0; i < _blockSize; ++i) {
    [[_leftBlocks objectAtIndex:i] clear];
    [[_rightBlocks objectAtIndex:i] clear];
  }

  // reassign button titles
  for (int i = 0; i < _blockSize; ++i) {
    MatchingBlock *left = [_leftBlocks objectAtIndex:i],
                  *right = [_rightBlocks objectAtIndex:i];
    [left setButtonTitle:[words objectAtIndex:i]];
    [left reappear];
    [right setButtonTitle:[shuffledMeanings objectAtIndex:i]];
    [right reappear];
  }
}

#pragma mark Callbacks

- (void)clearPairWithLeftIndex:(int)leftIndex
                withRightIndex:(int)rightIndex
                    withResult:(BOOL)result {
  if (result) {
    // correct pair
    [[_leftBlocks objectAtIndex:leftIndex] clear];
    [[_rightBlocks objectAtIndex:rightIndex] clear];
    _blockSize--;

    // if all cleared, attack
    if (_blockSize == 0) {
      CombatScene *scene = (CombatScene *)self.parent;
      [scene attackWithCharacter:-1 withType:0];
      // redeploy
      [self reDeployBlocks];
    }
  } else {
    // wrong pair, shake them
    [[_leftBlocks objectAtIndex:leftIndex] shakeOnView:nil];
    [[_rightBlocks objectAtIndex:rightIndex] shakeOnView:self];
    // enemy's turn to attack
    CombatScene *scene = (CombatScene *)self.parent;
    [scene attackWithCharacter:1 withType:0];
  }
}

@end