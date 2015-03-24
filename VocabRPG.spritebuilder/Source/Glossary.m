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
  cell.contentSize = CGSizeMake(1, 20);
  
  // label the cell with word
  Word *word = [_words objectAtIndex:index];
  NSString *labelString = [NSString stringWithFormat:@"%@: %@, PROF: %d", word.word, word.definition, word.proficiency];
  CCLabelTTF* label = [CCLabelTTF labelWithString:labelString fontName:@"HelveticaNeue" fontSize:12];
  label.positionType = CCPositionTypeNormalized;
  label.position = ccp(0.5f, 0.5f);
  
  [cell addChild:label];
  
  return cell;
}

- (NSUInteger)tableViewNumberOfRows:(CCTableView *)tableView {
  return numberOfRows;
}

@end
