//
//  Enemy.h
//  VocabRPG
//
//  Created by Junjia He on 2/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"
#import "Character.h"

@interface Enemy : CCSprite <Character>

@property (nonatomic, readonly) int healthPoint;

@end
