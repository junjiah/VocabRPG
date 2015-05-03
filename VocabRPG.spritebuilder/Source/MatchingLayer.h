//
//  MatchingLayout.h
//  VocabRPG
//
//  Created by Junjia He on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

@protocol VocabularyDataSource <NSObject>

- (NSDictionary *)generateWordMeaningPairs;
- (NSArray *)getOneRightPairIndex;

@end

@interface MatchingLayer : CCNode

- (void)clearPairWithLeftIndex:(int)leftIndex
                withRightIndex:(int)rightIndex
                    withResult:(BOOL)result;
- (void)redeployBlocks;
- (void)clearAllButtons;
- (void)setAllButtonTouchableAs:(BOOL)touchable;
- (NSArray *)getOneRightPairBlock;

@end
