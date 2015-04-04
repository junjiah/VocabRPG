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

/**
 *  Number of rounds per game.
 */
static const double NUMBER_OF_ROUND = 2;

@implementation CombatLayer {
  CCPhysicsNode *_physicsNode;
  CCSprite *_background;
  Hero *_hero;
  Enemy *_enemy;
  __weak CombatScene *_parentController;

  int _currentLevel, _currentRound;
  
  CGPoint _initBackgroundPosition;
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
  // init level/round info
  _currentLevel = 0;
  _currentRound = 0;
  
  _initBackgroundPosition = _background.positionInPoints;
}

- (void)goToNextLevel {
  // make moveBy action in % units
  _background.positionType = CCPositionTypeNormalized;
  
  // calculate how long should move
  int backgroundWidth = _background.contentSizeInPoints.width;
  int windowWidth = [[CCDirector sharedDirector] viewSize].width;
  double moveRatio =
      (backgroundWidth - windowWidth) / (NUMBER_OF_ROUND - 1) / backgroundWidth;

  // if reaching the maximum round, change the
  // background instead of moving forward
  ++_currentRound;
  _enemy.visible = NO;
  id delay = [CCActionDelay actionWithDuration:2];
  id enemyAppear = [CCActionCallBlock actionWithBlock:^(void) {
    _enemy.visible = YES;
    [_enemy reset];
    [_parentController updateHealthPointsOn:ENEMY_SIDE
                                 withUpdate:[_enemy healthPoint]];
  }];

  // TODO: potential async with count down?
  
  if (_currentRound == NUMBER_OF_ROUND) {
    id fadeOut = [CCActionFadeOut actionWithDuration:1];
    id switchBackground = [CCActionCallBlock actionWithBlock:^(void) {
      // switch the background and enemy
      CCSpriteFrame *newBackgroundFrame = [CCSpriteFrame frameWithImageNamed:@"dungeon-2.jpg"];
      [_background setSpriteFrame:newBackgroundFrame];
      [_enemy evolve];
    }];
    id fadeIn = [CCActionFadeIn actionWithDuration:1];
    [_background
        runAction:[CCActionSequence actions:delay, fadeOut, switchBackground,
                                            fadeIn, enemyAppear, nil]];
  } else {
    id moveLeft =
        [CCActionMoveBy actionWithDuration:2 position:ccp(-moveRatio, 0)];

    [_background
        runAction:[CCActionSequence actions:delay, moveLeft, enemyAppear, nil]];
  }
  
  // rebuild hero data (HP, strength)
  [_hero buildCharacter];
}

#pragma mark Message to characters

- (void)attackWithCharacter:(int)character
                   withType:(int)type {
  NSLog(@"ATTACK!");
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
  [collidee takeDamageBy:collider.strength];
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
