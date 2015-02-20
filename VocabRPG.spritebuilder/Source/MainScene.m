#import "MainScene.h"
#import "Obstacle.h"
#import "LeftBlock.h"
#import "RightBlock.h"

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

static int const BLOCK_X_MARGIN = 77;

@implementation MainScene {
  NSTimeInterval _sinceTouch;

  CCButton *_restartButton;

  BOOL _gameOver;
  CCLabelTTF *_nameLabel;

  int _points;

  NSMutableArray *_leftBlocks, *_rightBlocks;

  int _blockSize;
}

- (void)initialize {
  _character = (Character *)[CCBReader load:@"Character"];
  //  [_physicsNode addChild:_character];
  [self addObstacle];
  _timeSinceObstacle = 0.0f;

  // init blocks
  _leftBlocks = [NSMutableArray arrayWithCapacity:4];
  _rightBlocks = [NSMutableArray arrayWithCapacity:4];
  _blockSize = 4;

  int block_yspacing = 50, block_ystart = 40;

  for (int i = 0; i < _blockSize; ++i) {
    LeftBlock *left = (LeftBlock *)[CCBReader load:@"LeftBlock"];
    left.position = ccp(BLOCK_X_MARGIN, block_ystart + i * block_yspacing);
    [_leftBlocks addObject:left];
    [self addChild:left];

    RightBlock *right = (RightBlock *)[CCBReader load:@"RightBlock"];
    static CCPositionType rightCornerRef = {
        CCPositionUnitPoints, CCPositionUnitPoints,
        CCPositionReferenceCornerBottomRight};
    right.positionType = rightCornerRef;
    right.position = ccp(BLOCK_X_MARGIN, block_ystart + i * block_yspacing);
    [_rightBlocks addObject:right];
    [self addChild:right];
  }
}

- (void)didLoadFromCCB {
  self.userInteractionEnabled = TRUE;

  // set this class as delegate
  _physicsNode.collisionDelegate = self;

  _points = 0;

  [self initialize];
}

#pragma mark - Touch Handling

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
  //  if (!_gameOver) {
  //    [_character.physicsBody applyAngularImpulse:10000.f];
  //    _sinceTouch = 0.f;
  //
  //    @try {
  //      [_character flap];
  //    }
  //    @catch (NSException *ex) {
  //    }
  //  }
}

#pragma mark - Game Actions

- (void)gameOver {
  if (!_gameOver) {
    _gameOver = TRUE;
    _restartButton.visible = TRUE;

    _character.physicsBody.velocity =
        ccp(0.0f, _character.physicsBody.velocity.y);
    _character.rotation = 90.f;
    _character.physicsBody.allowsRotation = FALSE;
    [_character stopAllActions];

    CCActionMoveBy *moveBy =
        [CCActionMoveBy actionWithDuration:0.2f position:ccp(-2, 2)];
    CCActionInterval *reverseMovement = [moveBy reverse];
    CCActionSequence *shakeSequence =
        [CCActionSequence actionWithArray:@[ moveBy, reverseMovement ]];
    CCActionEaseBounce *bounce =
        [CCActionEaseBounce actionWithAction:shakeSequence];

    [self runAction:bounce];
  }
}

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
