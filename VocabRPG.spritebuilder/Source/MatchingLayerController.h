//
//  MatchingLayerController.h
//  VocabRPG
//
//  Created by Junjia He on 2/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MatchingLayer.h"

static const int DISPLAY_WORD_NUM = 2;

@interface MatchingLayerController : NSObject <VocabularyDataSource>

- (id)initWithView:(MatchingLayer *)view;
- (NSDictionary *)generateWordMeaningPairs;

@end
