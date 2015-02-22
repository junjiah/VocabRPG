//
//  MatchingLayerController.m
//  VocabRPG
//
//  Created by Junjia He on 2/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "MatchingLayerController.h"
#import "MatchingLayer.h"
#import "MatchingBlock.h"
#import "MemorizationModel.h"
#import "CombatLayer.h"

@implementation MatchingLayerController {
  MemorizationModel *_model;
  NSMutableArray *correctWordMap;
  int _pressedRecords[2];

  __weak MatchingLayer *_view;
}

- (id)initWithView:(MatchingLayer *)view {
  _view = view;
  _model = [MemorizationModel new];
  _pressedRecords[0] = -1;
  _pressedRecords[1] = -1;
  return self;
}

- (NSDictionary *)generateWordMeaningPairs {
  // get next 4 word-meaning pairs
  NSMutableArray *words = [NSMutableArray new],
                 *meanings = [NSMutableArray new];
  for (int i = 0; i < DISPLAY_WORD_NUM; ++i) {
    NSArray *wordPair = [[_model getNextPair] componentsSeparatedByString:@":"];
    [words addObject:[wordPair objectAtIndex:0]];
    [meanings addObject:[wordPair objectAtIndex:1]];
  }
  correctWordMap = [NSMutableArray arrayWithObjects:@0, @1, @2, @3, nil];
  [MatchingLayerController shuffle:correctWordMap];

  NSMutableDictionary *toReturn = [NSMutableDictionary dictionary];
  NSMutableArray *shuffledMeanings = [NSMutableArray arrayWithArray:meanings];
  for (int i = 0; i < DISPLAY_WORD_NUM; ++i) {
    [shuffledMeanings
                 setObject:[meanings objectAtIndex:i]
        atIndexedSubscript:[[correctWordMap objectAtIndex:i] unsignedIntValue]];
  }
  [toReturn setObject:words forKey:@"words"];
  [toReturn setObject:shuffledMeanings forKey:@"meanings"];
  return toReturn;
}

#pragma mark Callbacks

/**
 *  Callback to check pressed records and correctness.
 *
 *  @param sender pressed button
 */
- (void)blockPressed:(id)sender {
  NSArray *parts = [((CCButton *)sender).name componentsSeparatedByString:@"_"];
  NSString *side = [parts objectAtIndex:0];
  int buttonIndex = [[parts objectAtIndex:1] intValue];

  int column = [side isEqualToString:@"left"] ? 0 : 1;
  _pressedRecords[column] = buttonIndex;

  // check answer if both column pressed
  if (_pressedRecords[0] > -1 && _pressedRecords[1] > -1) {
    BOOL correctMath =
        [[correctWordMap objectAtIndex:_pressedRecords[0]] intValue] ==
        _pressedRecords[1];
    
    [_view clearPairWithLeftIndex:_pressedRecords[0]
                   withRightIndex:_pressedRecords[1]
                       withResult:correctMath];
    // reset pressed records
    _pressedRecords[0] = -1;
    _pressedRecords[1] = -1;
  }
}

#pragma mark Class methods

+ (void)shuffle:(NSMutableArray *)array {
  NSUInteger count = [array count];
  for (NSUInteger i = 0; i < count; ++i) {
    NSInteger remainingCount = count - i;
    NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t)remainingCount);
    [array exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
  }
}

@end
