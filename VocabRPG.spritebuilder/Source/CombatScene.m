#import "CombatScene.h"
#import "CombatLayer.h"
#import "MatchingLayer.h"

@implementation CombatScene {
  MatchingLayer *_matchingLayer;
  CombatLayer *_combatLayer;
  
  CCLabelTTF *_heroHealth, *_enemyHealth;
}

- (void)didLoadFromCCB {
  
}

- (void)restart {
  CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
  [[CCDirector sharedDirector] replaceScene:scene];
}

- (void)attackWithCharacter:(int)character withType:(int)type {
  [_combatLayer attackWithCharacter:character withType:type withStrength:20];
}

- (void)updateHealthPointsOn:(int)side withUpdate:(int)value {
  if (side == -1) {
    [_heroHealth setString:[NSString stringWithFormat:@"HP %d", value]];
  } else {
    [_enemyHealth setString:[NSString stringWithFormat:@"HP %d", value]];
  }
}

@end
