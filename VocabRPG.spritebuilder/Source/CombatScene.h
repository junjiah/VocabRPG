#import "CCNode.h"

@interface CombatScene: CCNode <CCPhysicsCollisionDelegate>

- (void)attackWithCharacter:(int)character withType:(int)type;
- (void)updateHealthPointsOn:(int)side withUpdate:(int)value;

@end
