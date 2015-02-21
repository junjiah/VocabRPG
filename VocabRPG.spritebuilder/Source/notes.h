- (void)didLoadFromCCB {
  self.physicsBody.collisionType = @"goal";
  self.physicsBody.sensor = YES;
}

#import "Obstacle.h"

@implementation Obstacle {
  CCNode *_topPipe;
  CCNode *_bottomPipe;
}

#define ARC4RANDOM_MAX      0x100000000

// visibility on a 3,5-inch iPhone ends a 88 points and we want some meat
static const CGFloat minimumYPosition = 200.f;
// visibility ends at 480 and we want some meat
static const CGFloat maximumYPosition = 380.f;

- (void)didLoadFromCCB {
  _topPipe.physicsBody.collisionType = @"level";
  _topPipe.physicsBody.sensor = YES;

  _bottomPipe.physicsBody.collisionType = @"level";
  _bottomPipe.physicsBody.sensor = YES;
}

- (void)setupRandomPosition {
  // value between 0.f and 1.f
  CGFloat random = ((double)arc4random() / ARC4RANDOM_MAX);
  CGFloat range = maximumYPosition - minimumYPosition;
  self.position = ccp(self.position.x, minimumYPosition + (random * range));
}

@end

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

