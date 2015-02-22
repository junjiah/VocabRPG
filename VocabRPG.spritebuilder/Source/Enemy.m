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
  actionRotateRight = [CCActionRotateBy actionWithDuration:0.2f angle:30.f];
  actionRotateLeft = [CCActionRotateBy actionWithDuration:0.4f angle:-30.f];
  self.physicsBody.collisionType = @"enemy";
}

- (void)takeDamage {
  [self runAction:[CCActionSequence actions:actionRotateRight, actionRotateLeft, nil]];
}

- (void)moveBack {
  [self.physicsBody applyImpulse:ccp(2 * FORWARD_IMPULSE, 0)];
}

@end
