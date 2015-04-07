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

static const double BACKGROUND_WIDTH = 512, BACKGROUND_HEIGHT = 312;

@implementation CombatLayer {
  CCPhysicsNode *_physicsNode;
  CCSprite *_background;
  Hero *_hero;
  Enemy *_enemy;
  __weak CombatScene *_parentController;

  int _currentLevel, _currentRound;

  CCNodeColor* _whiteBackground;
}

#pragma mark Set up

- (void)didLoadFromCCB {
  _physicsNode.collisionDelegate = self;
  _parentController = (CombatScene *)self.parent;
  
  // add a white background for transition
  _whiteBackground = [CCNodeColor nodeWithColor:[CCColor whiteColor]];
  _whiteBackground.opacity = 0;
  [self addChild:_whiteBackground z:10];
  
  // display both sides' health points
  [_parentController updateHealthPointsOn:HERO_SIDE
                               withUpdate:[_hero healthPoint]];
  [_parentController updateHealthPointsOn:ENEMY_SIDE
                               withUpdate:[_enemy healthPoint]];
  // init level/round info
  _currentLevel = 0;
  _currentRound = 0;

  // load the first level
  [self loadSceneInLevel:_currentLevel++];
}

- (void)goToNextRound {

  ++_currentRound;
  _enemy.visible = NO;
  id delay = [CCActionDelay actionWithDuration:2];
  id enemyAppear = [CCActionCallBlock actionWithBlock:^(void) {
    _enemy.visible = YES;
    [_enemy evolve];
    [_parentController updateHealthPointsOn:ENEMY_SIDE
                                 withUpdate:[_enemy healthPoint]];
  }];

  // TODO: potential async with count down?

  // if reaching the maximum round, change the
  // background instead of moving forward
  if (_currentRound == NUMBER_OF_ROUND) {
    // reset round counter
    _currentRound = 0;
    id fadeIn = [CCActionFadeIn actionWithDuration:0.7];
    id switchBackground = [CCActionCallBlock actionWithBlock:^(void) {
      // switch the background and enemy
      [_background removeFromParent];
      [self loadSceneInLevel:_currentLevel++];
    }];
    id fadeOut = [CCActionFadeOut actionWithDuration:0.7];
    [_whiteBackground
        runAction:[CCActionSequence actions:delay, fadeIn, switchBackground,
                                            fadeOut, enemyAppear, nil]];
  } else {
    // calculate how long should move
    int windowWidth = [[CCDirector sharedDirector] viewSize].width;
    double movePoints = (BACKGROUND_WIDTH - windowWidth) / (NUMBER_OF_ROUND - 1);

    id moveLeft =
        [CCActionMoveBy actionWithDuration:2 position:ccp(-movePoints, 0)];

    [_background
        runAction:[CCActionSequence actions:delay, moveLeft, enemyAppear, nil]];
  }

  // rebuild hero data (HP, strength)
  [_hero buildCharacter];
  [_parentController updateHealthPointsOn:HERO_SIDE
                               withUpdate:[_hero healthPoint]];
}

- (void)loadSceneInLevel:(int)level {
  NSString *sceneName = [NSString stringWithFormat:@"scene-l%d.png", level];
  _background = [CCSprite spriteWithImageNamed:sceneName];
  _background.anchorPoint = CGPointZero;
  
  // hard coded y-axis offset
  _background.position = ccp(0, -40);
  
  _background.scaleX = BACKGROUND_WIDTH / _background.contentSize.width;
  _background.scaleY = BACKGROUND_HEIGHT / _background.contentSize.height;
  
  [self addChild:_background z:-1];
}

#pragma mark Message to characters

- (void)attackWithCharacter:(int)character withType:(int)type {
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
