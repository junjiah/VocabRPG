//
//  Enemy.m
//  VocabRPG
//
//  Created by Junjia He on 2/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Enemy.h"

static id actionRotateLeft, actionRotateRight;

@implementation Enemy

- (void)didLoadFromCCB {
  self.physicsBody.collisionType = @"enemy";
  _healthPoint = 100;
}

- (void)takeDamageBy:(int)damage {
  [self runAction:[CCActionSequence actions:actionRotateRight, actionRotateLeft, nil]];
  _healthPoint -= damage;
}

- (void)moveBack {
  [self.physicsBody applyImpulse:ccp(2 * FORWARD_IMPULSE, 0)];
}

- (void)moveForward {
  [self.physicsBody applyImpulse:ccp(-1 * FORWARD_IMPULSE, 0)];
}

+ (void)initialize {
  actionRotateRight = [CCActionRotateBy actionWithDuration:0.2f angle:30.f];
  actionRotateLeft = [CCActionRotateBy actionWithDuration:0.4f angle:-30.f];
}

@end
