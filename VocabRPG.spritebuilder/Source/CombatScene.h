#import "CCNode.h"

static const int HERO_SIDE = -1;
static const int ENEMY_SIDE = 1;

@interface CombatScene: CCNode <CCPhysicsCollisionDelegate>

- (void)attackWithCharacter:(int)character withType:(int)type;
- (void)updateHealthPointsOn:(int)side withUpdate:(int)value;

@end
