//
//  VocabularySource.m
//  VocabRPG
//
//  Created by Junjia He on 2/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "MemorizationModel.h"
#import "Word.h"

static NSMutableArray *vocabulary;

static NSUInteger predefinedCounter = 0;

@implementation MemorizationModel

- (NSString *)getNextPair {
  NSUInteger index = (++predefinedCounter) % vocabulary.count;
  if (index == 0) {
    [MemorizationModel shuffle:vocabulary];
    predefinedCounter = 0;
  }
  Word *word = [vocabulary objectAtIndex:index];
  return [NSString stringWithFormat:@"%@:%@", word.word, word.definition];
}

- (void)setWord:(NSString *)word withMatch:(BOOL)matched {
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

+ (void)initialize {
  NSString *vocabList = [[NSBundle mainBundle] pathForResource: @"TOEFL-test" ofType: @"tsv"];
  NSString *vocabFile = [[NSString alloc] initWithContentsOfFile:vocabList encoding:NSUTF8StringEncoding error:nil];
  NSArray *allLines = [vocabFile componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  
  vocabulary = [NSMutableArray new];
  for (NSString *line in allLines) {
    if ([line length] == 0) {
      break;
    }
    
    NSArray *parts = [line componentsSeparatedByString:@"\t"];
    Word *w = [[Word alloc] initWithWord:[parts objectAtIndex:0] ofDefinition:[parts objectAtIndex:2]];
    [vocabulary addObject:w];
  }
  [MemorizationModel shuffle:vocabulary];
}

@end
