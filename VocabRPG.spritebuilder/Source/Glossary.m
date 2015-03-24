//
//  Glossary.m
//  VocabRPG
//
//  Created by Junjia He on 3/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Glossary.h"
#import "Word.h"
#import "MemoryModel.h"

@implementation Glossary {
  NSMutableArray *_words;
  NSUInteger numberOfRows;
}

- (id)init {
  self = [super init];
  if (self) {
    // retrieve memorized vocabulary from core data
    MemoryModel *memoryModel = [MemoryModel sharedMemoryModel];
    _words = [memoryModel retreiveAllWords];
    numberOfRows = _words.count;
  }
  return self;
}

- (CCTableViewCell *)tableView:(CCTableView *)tableView nodeForRowAtIndex:(NSUInteger)index {
  CCTableViewCell* cell = [CCTableViewCell node];
  
  cell.contentSizeType = CCSizeTypeMake(CCSizeUnitNormalized, CCSizeUnitPoints);
  cell.contentSize = CGSizeMake(1, 24);
  
  // Color every other row differently
  CCNodeColor* bg;
  if (index % 2 != 0) bg = [CCNodeColor nodeWithColor:[CCColor colorWithRed:1 green:0 blue:0 alpha:0.5]];
  else bg = [CCNodeColor nodeWithColor: [CCColor colorWithRed:0 green:1 blue:0 alpha:0.5]];
  
  bg.userInteractionEnabled = NO;
  bg.contentSizeType = CCSizeTypeNormalized;
  bg.contentSize = CGSizeMake(1, 1);
  [cell addChild:bg];
  
  // Create a label with the row number
  Word *word = [_words objectAtIndex:index];
  NSString *label = [NSString stringWithFormat:@"%@: %@, PROF: %d", word.word, word.definition, word.proficiency];
  CCLabelTTF* lbl = [CCLabelTTF labelWithString:label fontName:@"HelveticaNeue" fontSize:18];
  lbl.positionType = CCPositionTypeNormalized;
  lbl.position = ccp(0.5f, 0.5f);
  
  [cell addChild:lbl];
  
  return cell;
}

- (NSUInteger)tableViewNumberOfRows:(CCTableView *)tableView {
  return numberOfRows;
}

@end
