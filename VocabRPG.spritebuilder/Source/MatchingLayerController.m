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
#import "MemoryModel.h"
#import "CombatLayer.h"
#import "Word.h"

@implementation MatchingLayerController {
  MemoryModel *_model;
  NSMutableArray *_correctWordMap;
  int _pressedRecords[2];
  NSString *_pressedWord;

  __weak MatchingLayer *_view;
}

- (id)initWithView:(MatchingLayer *)view {
  _view = view;
  _model = [MemoryModel sharedMemoryModel];
  _pressedRecords[0] = -1;
  _pressedRecords[1] = -1;
  return self;
}

- (NSDictionary *)generateWordMeaningPairs {
  // get next word-meaning pairs
  NSArray *retrievedWords = [_model getWordsWith:kDisplayWordNumber];
  NSMutableArray *words = [NSMutableArray new],
                 *meanings = [NSMutableArray new];
  
  for (Word *word in retrievedWords) {
    [words addObject:word.word];
    [meanings addObject:word.definition];
  }

  _correctWordMap = [NSMutableArray new];
  for (int i = 0; i < kDisplayWordNumber; ++i)
    [_correctWordMap addObject:@(i)];
    
  [MatchingLayerController shuffle:_correctWordMap];

  NSMutableDictionary *toReturn = [NSMutableDictionary dictionary];
  NSMutableArray *shuffledMeanings = [NSMutableArray arrayWithArray:meanings];
  for (int i = 0; i < kDisplayWordNumber; ++i) {
    [shuffledMeanings
                 setObject:[meanings objectAtIndex:i]
        atIndexedSubscript:[[_correctWordMap objectAtIndex:i] unsignedIntValue]];
  }
  [toReturn setObject:words forKey:@"words"];
  [toReturn setObject:shuffledMeanings forKey:@"meanings"];
  return toReturn;
}

- (NSArray *)getOneRightPairIndex {
  return [NSArray arrayWithObjects:@(0), [_correctWordMap objectAtIndex:0], nil];
}

#pragma mark Callbacks

/**
 *  Callback to check pressed records and correctness.
 *
 *  @param sender pressed button
 */
- (void)blockPressed:(id)sender {
  CCButton *button = (CCButton *)sender;
  NSArray *parts = [button.name componentsSeparatedByString:@"_"];
  NSString *side = [parts objectAtIndex:0];
  int buttonIndex = [[parts objectAtIndex:1] intValue];

  int column = [side isEqualToString:@"left"] ? 0 : 1;
  if (!column) {
    // if pressed left, record the actual word
    _pressedWord = button.title;
  }
  _pressedRecords[column] = buttonIndex;

  // check answer if both column pressed
  if (_pressedRecords[0] > -1 && _pressedRecords[1] > -1) {
    BOOL correctMatch =
        [[_correctWordMap objectAtIndex:_pressedRecords[0]] intValue] ==
        _pressedRecords[1];
    
    [_model setWord:_pressedWord withMatch:correctMatch];
    
    [_view clearPairWithLeftIndex:_pressedRecords[0]
                   withRightIndex:_pressedRecords[1]
                       withResult:correctMatch];
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
