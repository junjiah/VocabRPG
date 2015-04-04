//
//  CombatLayout.h
//  VocabRPG
//
//  Created by Junjia He on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface CombatLayer : CCNode <CCPhysicsCollisionDelegate>

- (void)attackWithCharacter:(int)character
                   withType:(int)type;

- (void)goToNextLevel;

@end
