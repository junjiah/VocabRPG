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
static const double kRoundNumber = 2;

static const double kBackgroundWidth = 512, kBackgroundHeight = 312;

static int sStartLevel = 0;

@implementation CombatLayer {
  CCPhysicsNode *_physicsNode;
  CCSprite *_background;
  Hero *_hero;
  Enemy *_enemy;
  __weak CombatScene *_parentController;

  int _currentLevel, _currentRound;

  CCNodeColor *_whiteBackground;
}

#pragma mark Set up

- (void)didLoadFromCCB {
  _physicsNode.collisionDelegate = self;
  _parentController = (CombatScene *)self.parent;

  // add a white background for transition
  _whiteBackground = [CCNodeColor nodeWithColor:[CCColor whiteColor]];
  _whiteBackground.opacity = 0;
  [self addChild:_whiteBackground z:10];

  // init level/round info
  _currentLevel = sStartLevel;
  _currentRound = 0;

  // load the first level
  [self loadSceneInLevel:_currentLevel++];

  // build the enemy
  [_enemy buildEnemyAtLevel:sStartLevel];

  // display both sides' health points
  [_parentController updateHealthPointsOn:HERO_SIDE
                               withUpdate:[_hero healthPoint]];
  [_parentController updateHealthPointsOn:ENEMY_SIDE
                               withUpdate:[_enemy healthPoint]];
}

- (void)goToNextRound {

  __block bool levelChanged = false;

  ++_currentRound;
  _enemy.visible = NO;
  id delay = [CCActionDelay actionWithDuration:2];
  id enemyAppear = [CCActionCallBlock actionWithBlock:^(void) {
    _enemy.visible = YES;

    // if level changed, build enemy from pre-configured data
    // otherwise, evolve it
    if (!levelChanged)
      [_enemy evolve];
    else
      levelChanged = false;

    [_parentController updateHealthPointsOn:ENEMY_SIDE
                                 withUpdate:[_enemy healthPoint]];
  }];

  // TODO: potential async with count down?

  // if reaching the maximum round, change the
  // background instead of moving forward
  if (_currentRound == kRoundNumber) {
    // indicate level change
    levelChanged = true;
    [self saveProgress];

    // reset round counter
    _currentRound = 0;
    id fadeIn = [CCActionFadeIn actionWithDuration:0.7];
    id switchBackground = [CCActionCallBlock actionWithBlock:^(void) {
      // switch the background and enemy
      [_enemy buildEnemyAtLevel:_currentLevel];
      [_background removeFromParent];
      [self loadSceneInLevel:_currentLevel++];
      // clear combo state
      [_hero clearComboState];
    }];
    id fadeOut = [CCActionFadeOut actionWithDuration:0.7];
    [_whiteBackground
        runAction:[CCActionSequence actions:delay, fadeIn, switchBackground,
                                            fadeOut, enemyAppear, nil]];
  } else {
    // calculate how long should move
    int windowWidth = [[CCDirector sharedDirector] viewSize].width;
    double movePoints = (kBackgroundWidth - windowWidth) / (kRoundNumber - 1);

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

  _background.scaleX = kBackgroundWidth / _background.contentSize.width;
  _background.scaleY = kBackgroundHeight / _background.contentSize.height;

  [self addChild:_background z:-1];
}

- (void)saveProgress {
  NSString *currentSaveSlot =
      [[NSUserDefaults standardUserDefaults] stringForKey:@"currentSaveSlot"];
  NSMutableArray *saves =
      [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"saves"];
  NSMutableDictionary *savedDataCopy = [NSMutableDictionary
      dictionaryWithDictionary:saves[[currentSaveSlot intValue]]];
  NSString *progress = [savedDataCopy objectForKey:@"progress"];

  int level = [[progress componentsSeparatedByString:@" "][1] intValue];
  NSString *newProgress = [NSString stringWithFormat:@"LEVEL %d", level + 1];
  [savedDataCopy setValue:newProgress forKey:@"progress"];

  saves[currentSaveSlot.intValue] = savedDataCopy;
  [[NSUserDefaults standardUserDefaults] synchronize];

  // DEBUG: retrieve the progress
  NSDictionary *savedData =
      [[[NSUserDefaults standardUserDefaults] arrayForKey:@"saves"]
          objectAtIndex:[currentSaveSlot intValue]];
  progress = [savedData objectForKey:@"progress"];
}

#pragma mark Message to characters

- (void)attackWithCharacter:(int)character withType:(int)type {
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

  [collidee takeDamageBy:collider.strength];
  [collider moveBack];
  // update HP labels in parent view
  [_parentController updateHealthPointsOn:collidee.side
                               withUpdate:[collidee healthPoint]];
  return NO;
}

// this callback is called when the character is to get back to
// its original position
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair
                      character:(CCNode *)character
                        barrier:(CCNode *)barrier {
  if (character.physicsBody.velocity.x != 0 &&
      ((id<Character>)character).side == -1) {
    // is hero and get back from attacking
    [_hero setParticleEffects];
  }
  character.physicsBody.velocity = ccp(0, 0);
  [character
      runAction:[CCActionMoveTo actionWithDuration:0.5f
                                          position:((id<Character>)character)
                                                       .initPosition]];
  return NO;
}

+ (void)setStartLevel:(int)level {
  sStartLevel = level;
}

@end
