//
//  Enemy.m
//  VocabRPG
//
//  Created by Junjia He on 2/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Enemy.h"
#import "Hero.h"

static id actionRotateLeft, actionRotateRight;
static const int START_HEALTH = 15;

// predefined list for orders of monster appearances
static NSMutableArray *MONSTER_LIST;

@implementation Enemy {
  double _initHeight;
  // indicating the order of current monster
  int _currentMonster;
}

- (void)didLoadFromCCB {
  self.physicsBody.collisionType = @"character";
  _healthPoint = START_HEALTH;
  _strength = 10;
  _initPosition = self.position;
  _side = 1;

  _initHeight = self.contentSizeInPoints.height * self.scaleY;
  _currentMonster = 0;
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
          postNotificationName:CHARACTER_DIED_NOTIFICATION
                        object:nil
                      userInfo:resultDict];
    }
  }];
  [self runAction:[CCActionSequence actions:actionRotateRight, actionRotateLeft,
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
  _healthPoint = START_HEALTH + _currentMonster * (3.2 * heroStats.strength);
  _strength += heroStats.healthPoint / 5;
}

+ (void)initialize {
  actionRotateRight = [CCActionRotateBy actionWithDuration:0.2f angle:30.f];
  actionRotateLeft = [CCActionRotateBy actionWithDuration:0.4f angle:-30.f];

  MONSTER_LIST =
      [NSMutableArray arrayWithObjects:@"archon-ice", @"minotaur",
                                       @"archon-fire", @"archon-3", nil];
}

@end
