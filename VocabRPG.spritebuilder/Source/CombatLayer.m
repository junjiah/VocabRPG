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

# pragma mark Set up

- (void)didLoadFromCCB {
  _physicsNode.collisionDelegate = self;
  _parentController = (CombatScene *)self.parent;
  // display both sides' health points
  [_parentController updateHealthPointsOn:HERO_SIDE withUpdate:[_hero healthPoint]];
  [_parentController updateHealthPointsOn:ENEMY_SIDE withUpdate:[_enemy healthPoint]];
}

# pragma mark Message to characters

- (void)attackWithCharacter:(int)character withType:(int)type withStrength:(int)strength {
  NSLog(@"ATTACK!");
  _attackStrength = strength;
  switch (character) {
    case 1:
      [_enemy moveForward];
      break;
    case -1:
      [_hero moveForward];
    default:
      break;
  }
}

# pragma mark Collision

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair
                              hero:(CCSprite *)hero
                             enemy:(CCNode *)enemy {
  // judge who collides whom by the velocity
  id<Character> collider, collidee;
  int side;
  if (hero.physicsBody.velocity.x == 0) {
    collider = _enemy;
    collidee = _hero;
    side = HERO_SIDE;
  } else {
    collider = _hero;
    collidee = _enemy;
    side = ENEMY_SIDE;
  }
  
  [collider moveBack];
  [collidee takeDamageBy:_attackStrength];
  // update HP labels in parent view
  [_parentController updateHealthPointsOn:side withUpdate:[collidee healthPoint]];
  return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair
                           hero:(CCNode *)hero
                        barrier:(CCNode *)barrier {
  _hero.physicsBody.velocity = ccp(0, 0);
  [_hero runAction:[CCActionMoveTo actionWithDuration:0.5f position:_hero.initPosition]];
  return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair
                           enemy:(CCNode *)enemy
                        barrier:(CCNode *)barrier {
  _enemy.physicsBody.velocity = ccp(0, 0);
  [_enemy runAction:[CCActionMoveTo actionWithDuration:0.5f position:_enemy.initPosition]];
  return NO;
}

@end
