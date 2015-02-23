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
