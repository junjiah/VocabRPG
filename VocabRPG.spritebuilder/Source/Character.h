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

- (void)takeDamageBy:(int)damage;
- (void)moveBack;
- (void)moveForward;

@end
