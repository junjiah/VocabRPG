#import "CCNode.h"

@interface CombatScene: CCNode <CCPhysicsCollisionDelegate>

- (void)attackWithCharacter:(int)character withType:(int)type;

@end
