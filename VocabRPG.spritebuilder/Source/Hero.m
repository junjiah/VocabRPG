//
//  Hero.m
//  VocabRPG
//
//  Created by Junjia He on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Hero.h"
#import "MemoryModel.h"

enum ComboState {
  kNoCombo = 1,
  kFirstCombo,
  kLastCombo
};

static id sActionRotateLeft, sActionRotateRight;

static CCParticleSystem *sComboParticle1, *sComboParticle2;

/**
 *  A structure to record hero's numerical status,
 *  which could be used by the enemy's adaptive evolution.
 */
static struct Stats stats;

@implementation Hero

@synthesize strength = _strength;

- (void)didLoadFromCCB {
  self.physicsBody.collisionType = @"character";
  [self buildCharacter];
  _initPosition = self.position;
  _side = -1;
  _comboState = kNoCombo;
}

- (int)strength {
  return _strength * _comboState;
}

- (void)clearComboState {
  _comboState = kNoCombo;
  [self setParticleEffects];
}

- (void)takeDamageBy:(int)damage {
  _comboState = kNoCombo;
  [self setParticleEffects];
  
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
  [self runAction:[CCActionSequence actions:sActionRotateLeft, sActionRotateRight,
                                            notify, nil]];
}

- (void)moveBack {
  // after attcking, add combo
  if (_comboState != kLastCombo)
    ++_comboState;
  [self.physicsBody applyImpulse:ccp(-2 * FORWARD_IMPULSE, 0)];
}

- (void)moveForward {
  [self.physicsBody applyImpulse:ccp(FORWARD_IMPULSE, 0)];
}

- (void)setParticleEffects {
  switch (_comboState) {
    case kNoCombo:
      [sComboParticle1 removeFromParent];
      [sComboParticle2 removeFromParent];
      break;
    case kFirstCombo:
      [self addChild:sComboParticle1];
      break;
    case kLastCombo:
      if (![self getChildByName:@"combo2" recursively:NO]) {
        [sComboParticle1 removeFromParent];
        [self addChild:sComboParticle2];
      }
  }
}

// OLD strategy, refer to README.md
- (void)buildCharacterDeprecated {
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

  // record status
  stats.healthPoint = _healthPoint;
  stats.strength = _strength;
}

- (void)buildCharacter {
  MemoryModel *memoryModel = [MemoryModel sharedMemoryModel];
  int memorizedVocabularySize = (int)[memoryModel getMemorizedVocabularySize];

  // a reasonable relationship between HP and vocabulary size
  _healthPoint = memorizedVocabularySize / 100 * memorizedVocabularySize / 100;
  _healthPoint = _healthPoint * 0.4 + 100;
  _healthPoint = MIN(_healthPoint, 9999);

  // array of size 20, for different proficiency levels
  NSArray *memorizedVocabularyCounts =
      [memoryModel getMemorizedVocabularyCountsInAllProficiencyLevels];

  if (memorizedVocabularySize == 0) {
    // hard-coded strength when no memorized vocabulary
    _strength = 15;
  } else {
    double p = 0, pMax = 1 - pow(0.95, 20);
    for (int i = 1; i <= 20; ++i) {
      p += (1.0 - pow(0.95, i)) *
           [[memorizedVocabularyCounts objectAtIndex:i - 1] doubleValue];
    }
    // take the average
    p /= memorizedVocabularySize;
    _strength = MAX(100 * (p / pMax), 1);
  }

  // record status
  stats.healthPoint = _healthPoint;
  stats.strength = _strength;
}

+ (void)initialize {
  sActionRotateLeft = [CCActionRotateBy actionWithDuration:0.2f angle:-30.f];
  sActionRotateRight = [CCActionRotateBy actionWithDuration:0.4f angle:30.f];
  sComboParticle1 = (CCParticleSystem *)[CCBReader load:@"HeroCombo1"];
  sComboParticle2 = (CCParticleSystem *)[CCBReader load:@"HeroCombo2"];
  sComboParticle1.positionType = sComboParticle2.positionType = CCPositionTypeNormalized;
  sComboParticle1.anchorPoint = sComboParticle2.anchorPoint = ccp(0.5f, 0.5f);
  sComboParticle1.position = sComboParticle2.position = ccp(0.5f, 0.5f);
  sComboParticle1.scale = sComboParticle2.scale = 0.5;
  
  sComboParticle1.name = @"combo1";
  sComboParticle2.name = @"combo2";
}

+ (struct Stats)getHeroStatus {
  return stats;
}

@end
