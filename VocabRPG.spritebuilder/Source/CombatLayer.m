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

static const double FORWARD_FORCE = 1000;

@implementation CombatLayer {
  CCPhysicsNode *_physicsNode;
  Hero *_hero;
  Enemy *_enemy;
}

- (void)didLoadFromCCB {
  _physicsNode.collisionDelegate = self;
}

- (void)attack {
  NSLog(@"ATTACK!");
  [_hero.physicsBody applyImpulse:ccp(FORWARD_FORCE, 0)];
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair
                              hero:(CCSprite *)hero
                             enemy:(CCNode *)enemy {
  [hero.physicsBody applyImpulse:ccp(-FORWARD_FORCE * 2, 0)];
  id actionRotateLeft = [CCActionRotateBy actionWithDuration:0.2f angle:30.f];
  id actionRotateRight = [CCActionRotateBy actionWithDuration:0.4f angle:-30.f];
  [enemy runAction:[CCActionSequence actions:actionRotateLeft, actionRotateRight, nil]];
  return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair
                           hero:(CCNode *)hero
                        barrier:(CCNode *)barrier {
  hero.physicsBody.velocity = ccp(0, 0);
  return NO;
}

@end
