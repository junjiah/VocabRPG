#import "CombatScene.h"
#import "CombatLayer.h"
#import "MatchingLayer.h"

@implementation CombatScene {
  MatchingLayer *_matchingLayer;
  CombatLayer *_combatLayer;
  
  CCLabelTTF *_heroHealth, *_enemyHealth;
  int _heroHealthValue, _enemyHealthValue;
}

- (void)didLoadFromCCB {
  _heroHealthValue = _enemyHealthValue = 100;
  
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
    _heroHealthValue += value;
    [_heroHealth setString:[NSString stringWithFormat:@"HP %d", _heroHealthValue]];
  } else {
    _enemyHealthValue += value;
    [_enemyHealth setString:[NSString stringWithFormat:@"HP %d", _enemyHealthValue]];
  }
}

@end
