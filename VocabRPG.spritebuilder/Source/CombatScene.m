#import "CombatScene.h"
#import "CombatLayer.h"
#import "MatchingLayer.h"

@implementation CombatScene {
  MatchingLayer *_matching;
  CombatLayer *_combat;
}

- (void)initialize {

}

- (void)didLoadFromCCB {
  self.userInteractionEnabled = TRUE;
  [self initialize];
}

#pragma mark - Game Actions

- (void)restart {
  CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
  [[CCDirector sharedDirector] replaceScene:scene];
}

#pragma mark - Obstacle Spawning

- (void)attackWithCharacter:(int)character withType:(int)type {
  [_combat attack];
}



@end
