//
//  VocabularySource.m
//  VocabRPG
//
//  Created by Junjia He on 2/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "MemorizationModel.h"

static NSArray *predefinedWords, *predefinedMeanings;

static long predefinedCounter = 0;

@implementation MemorizationModel

- (NSString *)getNextPair {
  unsigned int index = (predefinedCounter++) % 4;
  NSString *word = [predefinedWords objectAtIndex:index],
           *meaning = [predefinedMeanings objectAtIndex:index];
  return [NSString stringWithFormat:@"%@:%@", word, meaning];
}

- (void)setWord:(NSString *)word withMatch:(BOOL)matched {
}

+ (void)initialize {
  predefinedWords = @[ @"Apple", @"Banana", @"Pear", @"Orange" ];
  predefinedMeanings = @[ @"苹果(A)", @"香蕉(B)", @"梨子(P)", @"橘子(O)" ];
}

@end
