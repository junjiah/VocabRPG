//
//  Hero.m
//  VocabRPG
//
//  Created by Junjia He on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Hero.h"
#import "MemoryModel.h"

static id actionRotateLeft, actionRotateRight;
static const int START_HEALTH = 600;

@implementation Hero

- (void)didLoadFromCCB {
  self.physicsBody.collisionType = @"character";
  [self buildCharacter];
  _initPosition = self.position;
  _side = -1;
}

- (void)takeDamageBy:(int)damage {
  _healthPoint = MAX(_healthPoint - damage, 0);
  id notify = [CCActionCallBlock actionWithBlock:^(void) {
    if (_healthPoint <= 0) {
      // send winning notification
      NSDictionary *resultDict =
          [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1]
                                      forKey:@"winSide"];
      [[NSNotificationCenter defaultCenter]
          postNotificationName:CHARACTER_DIED_NOTIFICATION
                        object:nil
                      userInfo:resultDict];
    }
  }];
  [self runAction:[CCActionSequence actions:actionRotateLeft, actionRotateRight,
                                            notify, nil]];
}

- (void)moveBack {
  [self.physicsBody applyImpulse:ccp(-2 * FORWARD_IMPULSE, 0)];
}

- (void)moveForward {
  [self.physicsBody applyImpulse:ccp(FORWARD_IMPULSE, 0)];
}

- (void)buildCharacter {
  MemoryModel *memoryModel = [MemoryModel sharedMemoryModel];
  int memorizedVocabularySize = (int)[memoryModel getMemorizedVocabularySize];

  // a reasonable relationship between HP and vocabulary size
  _healthPoint = memorizedVocabularySize / 100 * memorizedVocabularySize / 100;
  _healthPoint = _healthPoint * 0.4 + 20;
  _healthPoint = MIN(_healthPoint, 9999);

  NSArray *memorizedVocabularyCounts =
      [memoryModel getMemorizedVocabularyCounts];
  // TODO: this formula may not be reasonable...
  _strength = 10 + [[memorizedVocabularyCounts objectAtIndex:1] intValue] +
              [[memorizedVocabularyCounts objectAtIndex:2] intValue] * 5 +
              [[memorizedVocabularyCounts objectAtIndex:3] intValue] * 100;
  _strength = MIN(_strength, 9999);
}

+ (void)initialize {
  actionRotateLeft = [CCActionRotateBy actionWithDuration:0.2f angle:-30.f];
  actionRotateRight = [CCActionRotateBy actionWithDuration:0.4f angle:30.f];
}

@end
