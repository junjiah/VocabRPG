//
//  Enemy.m
//  VocabRPG
//
//  Created by Junjia He on 2/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Enemy.h"

static id actionRotateLeft, actionRotateRight;
static const int startHealth = 20;

@implementation Enemy

- (void)didLoadFromCCB {
  self.physicsBody.collisionType = @"character";
  _healthPoint = startHealth;
  _initPosition = self.position;
  _side = 1;
}

- (void)takeDamageBy:(int)damage {
  _healthPoint -= damage;
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

- (void)reset {
  _healthPoint = startHealth;
}

- (void)evolve {
  [self setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"pig.png"]];
  self.scale = 0.2;
  self.position = _initPosition;
}

+ (void)initialize {
  actionRotateRight = [CCActionRotateBy actionWithDuration:0.2f angle:30.f];
  actionRotateLeft = [CCActionRotateBy actionWithDuration:0.4f angle:-30.f];
}

@end
