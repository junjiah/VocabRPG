//
//  Character.h
//  VocabRPG
//
//  Created by Junjia He on 2/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"

static const double FORWARD_IMPULSE = 1000;
static NSString * const CHARACTER_DIED_NOTIFICATION = @"CharacterDidDieNotification";

@protocol Character <NSObject>

@property (nonatomic, readonly) int healthPoint;
@property (nonatomic, readonly) int side;
@property (nonatomic, readonly) int strength;
@property (nonatomic, readonly) CGPoint initPosition;

- (void)takeDamageBy:(int)damage;
- (void)moveBack;
- (void)moveForward;

@end
