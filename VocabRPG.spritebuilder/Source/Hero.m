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
  actionRotateLeft = [CCActionRotateBy actionWithDuration:0.2f angle:-30.f];
  actionRotateRight = [CCActionRotateBy actionWithDuration:0.4f angle:30.f];
  self.physicsBody.collisionType = @"hero";
}

- (void)takeDamage {
  [self runAction:[CCActionSequence actions:actionRotateLeft, actionRotateRight, nil]];
}

- (void)moveBack {
  [self.physicsBody applyImpulse:ccp(-2 * FORWARD_IMPULSE, 0)];
}

@end
