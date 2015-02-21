//
//  MatchingLayout.m
//  VocabRPG
//
//  Created by Junjia He on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "MatchingLayer.h"
#import "MatchingBlock.h"
#import "MatchingLayerController.h"

@implementation MatchingLayer {
  MatchingLayerController *controller;
}

- (void)didLoadFromCCB {
  controller = [MatchingLayerController new];
  for (MatchingBlock *b in [controller generateMatchingBlock]) {
    [self addChild:b];
  }
}

@end
