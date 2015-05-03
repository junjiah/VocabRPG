//
//  Enemy.m
//  VocabRPG
//
//  Created by Junjia He on 2/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Enemy.h"
#import "Hero.h"

static id sActionRotateLeft, sActionRotateRight;
static int sLevelStartHealth = 0;

// predefined list for orders of monster appearances
static NSMutableArray *MONSTER_LIST;

@implementation Enemy {
  double _initHeight;
  // indicating the order of current monster
  int _currentMonster;
}

- (void)didLoadFromCCB {
  self.physicsBody.collisionType = @"character";

  _initPosition = self.position;
  _side = 1;

  _initHeight = self.contentSizeInPoints.height * self.scaleY;
  _currentMonster = 0;
}

- (void)buildEnemyAtLevel:(int)level {
  // TODO: currently only four levels
  static int HP[] = {100, 200, 300, 500};
  static int STR[] = {10, 20, 30, 40};
  static const int LEVEL_NUMBER = 4;
  sLevelStartHealth = HP[level % LEVEL_NUMBER];
  _healthPoint = sLevelStartHealth;
  _strength = STR[level % LEVEL_NUMBER];
}

- (void)takeDamageBy:(int)damage {
  _healthPoint = MAX(_healthPoint - damage, 0);
  id notify = [CCActionCallBlock actionWithBlock:^(void) {
    if (_healthPoint <= 0) {
      // send winning notification
      NSDictionary *resultDict =
          [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:-1]
                                      forKey:@"winSide"];
      [[NSNotificationCenter defaultCenter]
          postNotificationName:kCharacterDiedNotification
                        object:nil
                      userInfo:resultDict];
    }
  }];
  [self runAction:[CCActionSequence actions:sActionRotateRight, sActionRotateLeft,
                                            notify, nil]];
}

- (void)moveBack {
  [self.physicsBody applyImpulse:ccp(2 * FORWARD_IMPULSE, 0)];
}

- (void)moveForward {
  [self.physicsBody applyImpulse:ccp(-1 * FORWARD_IMPULSE, 0)];
}

- (void)evolve {
  NSString *monsterName =
      [MONSTER_LIST objectAtIndex:(_currentMonster++) % MONSTER_LIST.count];
  [self setSpriteFrame:[CCSpriteFrame
                           frameWithImageNamed:
                               [monsterName stringByAppendingString:@".png"]]];

  self.position = _initPosition;
  
  // get hero's status, use a heuristic to calculate the moster's ability
  struct Stats heroStats = [Hero getHeroStatus];
  _healthPoint = sLevelStartHealth + _currentMonster * (3.2 * heroStats.strength);
  _strength += heroStats.healthPoint / 5;
}

+ (void)initialize {
  sActionRotateRight = [CCActionRotateBy actionWithDuration:0.2f angle:30.f];
  sActionRotateLeft = [CCActionRotateBy actionWithDuration:0.4f angle:-30.f];

  MONSTER_LIST =
      [NSMutableArray arrayWithObjects:@"archon-ice", @"minotaur",
                                       @"archon-fire", @"archon-3", nil];
}

@end
