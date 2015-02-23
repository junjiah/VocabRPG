//
//  Block.h
//  VocabRPG
//
//  Created by Junjia He on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "MatchingLayer.h"

@interface MatchingBlock : CCNode

@property (nonatomic, strong) NSString *buttonName;
@property (nonatomic, strong) NSString *buttonTitle;

- (void)clear;
- (void)reappear;
- (void)shakeOnView:(MatchingLayer *)view;

@end
