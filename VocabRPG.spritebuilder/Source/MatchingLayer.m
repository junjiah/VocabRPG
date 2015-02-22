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
  
  id <VocabularyDataSource> dataSource;
}

- (void)didLoadFromCCB {
  dataSource = [[MatchingLayerController alloc] initWithView:self];
  NSDictionary *vocabularyData = [dataSource generateWordMeaningPairs];
  [self deployBlocks:vocabularyData];
}

- (void)deployBlocks:(NSDictionary *)wordMeaningPairs {
  NSMutableArray *words = [wordMeaningPairs objectForKey:@"words"],
                 *shuffledMeanings =
                     [wordMeaningPairs objectForKey:@"meanings"];
  // init blocks
  _leftBlocks = [NSMutableArray arrayWithCapacity:4];
  _rightBlocks = [NSMutableArray arrayWithCapacity:4];

  //*******DEBUGG!
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

# pragma mark Callbacks

- (void)clearPair:(int)leftIndex withRightIndex:(int)rightIndex {
  [[_leftBlocks objectAtIndex:leftIndex] clear];
  [[_rightBlocks objectAtIndex:rightIndex] clear];
  _blockSize--;
  
  /***** DEBUG *****/
  _blockSize = 0;
  /***** DEBUG *****/
  
  // if all cleared, attack
  if (_blockSize == 0) {
    CombatScene *scene = (CombatScene *)self.parent;
    [scene attackWithCharacter:0 withType:0];
    _blockSize = DISPLAY_WORD_NUM;
  }
}

@end
