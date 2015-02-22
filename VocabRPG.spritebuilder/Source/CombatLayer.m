//
//  CombatLayout.m
//  VocabRPG
//
//  Created by Junjia He on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CombatLayer.h"
#import "CombatScene.h"
#import "MatchingBlock.h"
#import "Character.h"
#import "Hero.h"
#import "Enemy.h"

@implementation CombatLayer {
  CCPhysicsNode *_physicsNode;
  Hero *_hero;
  Enemy *_enemy;
  __weak CombatScene *_parentController;
  
  int _attackStrength;
}

- (void)didLoadFromCCB {
  _physicsNode.collisionDelegate = self;
  _parentController = (CombatScene *)self.parent;
}

- (void)attackWithCharacter:(int)character withType:(int)type withStrength:(int)strength {
  NSLog(@"ATTACK!");
  _attackStrength = strength;
  switch (character) {
    case 1:
      [_enemy.physicsBody applyImpulse:ccp(-FORWARD_IMPULSE, 0)];
      break;
    case -1:
      [_hero.physicsBody applyImpulse:ccp(FORWARD_IMPULSE, 0)];
    default:
      break;
  }
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair
                              hero:(CCSprite *)hero
                             enemy:(CCNode *)enemy {
  // judge who collides whom by the velocity
  id<Character> collider, collidee;
  int side;
  if (hero.physicsBody.velocity.x == 0) {
    collider = _enemy;
    collidee = _hero;
    side = -1;
  } else {
    collider = _hero;
    collidee = _enemy;
    side = 1;
  }
  
  [collider moveBack];
  [collidee takeDamage];
  // update HP labels in parent view
  [_parentController updateHealthPointsOn:side withUpdate:-1 * _attackStrength];
  return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair
                           hero:(CCNode *)hero
                        barrier:(CCNode *)barrier {
  hero.physicsBody.velocity = ccp(0, 0);
  return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair
                           enemy:(CCNode *)enemy
                        barrier:(CCNode *)barrier {
  enemy.physicsBody.velocity = ccp(0, 0);
  return NO;
}

@end
