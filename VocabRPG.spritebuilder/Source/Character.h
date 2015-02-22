//
//  Character.h
//  VocabRPG
//
//  Created by Junjia He on 2/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"

static const double FORWARD_IMPULSE = 1000;

@protocol Character <NSObject>

- (void)takeDamage;
- (void)moveBack;

@end
