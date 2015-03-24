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

@end
