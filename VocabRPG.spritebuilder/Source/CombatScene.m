#import "CombatScene.h"

@interface CGPointObject : NSObject {
  CGPoint _ratio;
  CGPoint _offset;
  CCNode *__unsafe_unretained _child; // weak ref
}
@property(nonatomic, readwrite) CGPoint ratio;
@property(nonatomic, readwrite) CGPoint offset;
@property(nonatomic, readwrite, unsafe_unretained) CCNode *child;
+ (id)pointWithCGPoint:(CGPoint)point offset:(CGPoint)offset;
- (id)initWithCGPoint:(CGPoint)point offset:(CGPoint)offset;
@end

@implementation CombatScene

- (void)initialize {
  //  [_physicsNode addChild:_character];
  [self addObstacle];
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

- (void)addObstacle {
  //  Obstacle *obstacle = (Obstacle *)[CCBReader load:@"Obstacle"];
  //  CGPoint screenPosition = [self convertToWorldSpace:ccp(380, 0)];
  //  CGPoint worldPosition = [_physicsNode convertToNodeSpace:screenPosition];
  //  obstacle.position = worldPosition;
  //  [obstacle setupRandomPosition];
  ////  obstacle.zOrder = DrawingOrderPipes;
  //  [_physicsNode addChild:obstacle];
}

#pragma mark - Update

- (void)update:(CCTime)delta {
  //  _sinceTouch += delta;
  //
  //  _character.rotation = clampf(_character.rotation, -30.f, 90.f);
  //
  //  if (_character.physicsBody.allowsRotation) {
  //    float angularVelocity =
  //        clampf(_character.physicsBody.angularVelocity, -2.f, 1.f);
  //    _character.physicsBody.angularVelocity = angularVelocity;
  //  }
  //
  //  if ((_sinceTouch > 0.5f)) {
  //    [_character.physicsBody applyAngularImpulse:-40000.f * delta];
  //  }
  //
  //  _physicsNode.position =
  //      ccp(_physicsNode.position.x - (_character.physicsBody.velocity.x *
  //      delta),
  //          _physicsNode.position.y);
  //
  //  if (!_gameOver) {
  //    @try {
  //      _character.physicsBody.velocity = ccp(
  //          80.f, clampf(_character.physicsBody.velocity.y, -MAXFLOAT,
  //          200.f));
  //
  //      [super update:delta];
  //    }
  //    @catch (NSException *ex) {
  //    }
  //  }
}

//- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair
//                      character:(CCSprite *)character
//                          level:(CCNode *)level {
//  [self gameOver];
//  return TRUE;
//}
//
//- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair
//                      character:(CCNode *)character
//                           goal:(CCNode *)goal {
//  [goal removeFromParent];
//  _points++;
//  return TRUE;
//}

@end
