//
//  Word.m
//  VocabRPG
//
//  Created by Junjia He on 3/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Word.h"

@implementation Word

- (id)initWithWord:(NSString *)word
      ofDefinition:(NSString *)definition
     ofProficiency:(int)proficiency {
  _word = word;
  _definition = definition;
  _proficiency = proficiency;
  return self;
}

- (BOOL)isEqual:(id)other {
  if (other == self)
    return YES;
  if (!other || ![other isKindOfClass:[self class]])
    return NO;
  return [self isEqualToWord:other];
}

- (BOOL)isEqualToWord:(Word *)aWord {
  if (self == aWord)
    return YES;
  if (![_word isEqual:aWord.word])
    return NO;

  return YES;
}

- (NSUInteger)hash {
  return [_word hash];
}

@end
