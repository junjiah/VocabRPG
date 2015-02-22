//
//  CombatLayout.m
//  VocabRPG
//
//  Created by Junjia He on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CombatLayer.h"
#import "MatchingBlock.h"
#import "Hero.h"
#import "Enemy.h"

@implementation CombatLayer {
  Hero *_hero;
  Enemy *_enemy;
}

- (void)didLoadFromCCB {
}

- (void)attack:(NSNotification*)notification {
//  [_hero.physicsBody applyForce:ccp(1, 0)];
  NSLog(@"ATTACK!");
}

@end
