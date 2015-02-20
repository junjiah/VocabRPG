#import "CCNode.h"
#import "GamePlayScene.h"

@interface MainScene: CCNode <CCPhysicsCollisionDelegate>

@property (nonatomic, strong) Character* character;

@property (nonatomic, strong) CCPhysicsNode* physicsNode;

@property (nonatomic, assign) float timeSinceObstacle;

-(void) gameOver;

@end
