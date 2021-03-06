//
//  Hero.h
//  VocabRPG
//
//  Created by Junjia He on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"
#import "Character.h"

typedef enum ComboState ComboState;

@interface Hero : CCSprite <Character>

@property (nonatomic, readonly) int healthPoint;
@property (nonatomic, readonly) int side;
@property (nonatomic, readonly) int strength;
@property (nonatomic, readonly) CGPoint initPosition;
@property (nonatomic, readonly) ComboState comboState;

- (void)buildCharacter;
- (void)clearComboState;
- (void)setParticleEffects;

+ (struct Stats)getHeroStatus;

@end
