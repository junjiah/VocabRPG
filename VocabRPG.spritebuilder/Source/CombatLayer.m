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
  CCNode *_background;
  Hero *_hero;
  Enemy *_enemy;
  __weak CombatScene *_parentController;

  int _attackStrength;
}

#pragma mark Set up

- (void)didLoadFromCCB {
  _physicsNode.collisionDelegate = self;
  _parentController = (CombatScene *)self.parent;
  // display both sides' health points
  [_parentController updateHealthPointsOn:HERO_SIDE
                               withUpdate:[_hero healthPoint]];
  [_parentController updateHealthPointsOn:ENEMY_SIDE
                               withUpdate:[_enemy healthPoint]];
}

- (void)goToNextLevel {
  _enemy.visible = NO;
  id delay = [CCActionDelay actionWithDuration:2];
  id moveLeft = [CCActionMoveBy actionWithDuration:2 position:ccp(-0.2f, 0)];
  id enemyAppear = [CCActionCallBlock actionWithBlock:^(void) {
    _enemy.visible = YES;
    [_enemy reset];
    [_parentController updateHealthPointsOn:ENEMY_SIDE
                                 withUpdate:[_enemy healthPoint]];
  }];
  
  CGPoint p = _background.position;
  
  [_background
      runAction:[CCActionSequence actions:delay, moveLeft, enemyAppear, nil]];
}

#pragma mark Message to characters

- (void)attackWithCharacter:(int)character
                   withType:(int)type
               withStrength:(int)strength {
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

#pragma mark Collision

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair
                         character:(CCSprite *)character1
                         character:(CCSprite *)character2 {
  // judge who collides whom by the velocity
  id<Character> collider, collidee;
  if (character1.physicsBody.velocity.x == 0) {
    collider = (id<Character>)character2;
    collidee = (id<Character>)character1;
  } else {
    collider = (id<Character>)character1;
    collidee = (id<Character>)character2;
  }

  [collider moveBack];
  [collidee takeDamageBy:_attackStrength];
  // update HP labels in parent view
  [_parentController updateHealthPointsOn:collidee.side
                               withUpdate:[collidee healthPoint]];
  return NO;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair
                      character:(CCNode *)character
                        barrier:(CCNode *)barrier {
  character.physicsBody.velocity = ccp(0, 0);
  [character
      runAction:[CCActionMoveTo actionWithDuration:0.5f
                                          position:((id<Character>)character)
                                                       .initPosition]];
  return NO;
}

@end
