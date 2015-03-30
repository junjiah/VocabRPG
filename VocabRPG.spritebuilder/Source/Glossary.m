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

- (CCTableViewCell *)tableView:(CCTableView *)tableView
             nodeForRowAtIndex:(NSUInteger)index {
  CCTableViewCell *cell = [CCTableViewCell node];
  Word *word = [_words objectAtIndex:index];

  cell.contentSizeType = CCSizeTypeMake(CCSizeUnitNormalized, CCSizeUnitPoints);
  cell.contentSize = CGSizeMake(1, 20);

  CCNode *wordNode = [CCNode node], *definitionNode = [CCNode node],
         *proficiencyNode = [CCNode node];
  CCLabelTTF *
      wordLabel = [CCLabelTTF labelWithString:word.word
                                     fontName:@"HelveticaNeue"
                                     fontSize:12],
     *definitionLabel = [CCLabelTTF labelWithString:word.definition
                                           fontName:@"HelveticaNeue"
                                           fontSize:12],
     *proficiencyLabel = [CCLabelTTF
         labelWithString:[NSString stringWithFormat:@"%d", word.proficiency]
                fontName:@"HelveticaNeue"
                fontSize:12];

  [wordNode addChild:wordLabel];
  [definitionNode addChild:definitionLabel];
  [proficiencyNode addChild:proficiencyLabel];
  
  // I know this is ugly...
  float positions[3] = {0.2, 0.6, 0.9};
  int i = 0;
  for (CCNode *node in [NSArray arrayWithObjects:wordNode, definitionNode, proficiencyNode, nil]) {
    node.positionType = CCPositionTypeNormalized;
    node.position = ccp(positions[i++], 0.5f);
    [cell addChild:node];
  }

  return cell;
}

- (NSUInteger)tableViewNumberOfRows:(CCTableView *)tableView {
  return numberOfRows;
}

@end
