//
//  TitleScene.m
//  VocabRPG
//
//  Created by Junjia He on 4/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "TitleScene.h"

@implementation TitleScene

- (void)startNewGame {
  CCScene *scene = [CCBReader loadAsScene:@"CombatScene"];
  [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionCrossFadeWithDuration:1]];
}

- (void)continueGame {
  
}

@end
