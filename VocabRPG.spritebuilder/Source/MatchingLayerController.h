//
//  MatchingLayerController.h
//  VocabRPG
//
//  Created by Junjia He on 2/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MatchingLayer.h"

@interface MatchingLayerController : NSObject <VocabularyDataSource>

- (id)initWithView:(MatchingLayer *)view;
- (NSDictionary *)generateWordMeaningPairs;

@end
