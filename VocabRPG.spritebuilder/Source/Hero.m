//
//  Hero.m
//  VocabRPG
//
//  Created by Junjia He on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Hero.h"

static id actionRotateLeft, actionRotateRight;

@implementation Hero

- (void)didLoadFromCCB {
  self.physicsBody.collisionType = @"hero";
  _healthPoint = 100;
}

- (void)takeDamageBy:(int)damage {
  [self runAction:[CCActionSequence actions:actionRotateLeft, actionRotateRight, nil]];
  _healthPoint -= damage;
}

- (void)moveBack {
  [self.physicsBody applyImpulse:ccp(-2 * FORWARD_IMPULSE, 0)];
}

- (void)moveForward {
  [self.physicsBody applyImpulse:ccp(FORWARD_IMPULSE, 0)];
}

+ (void)initialize {
  actionRotateLeft = [CCActionRotateBy actionWithDuration:0.2f angle:-30.f];
  actionRotateRight = [CCActionRotateBy actionWithDuration:0.4f angle:30.f];
}

@end
