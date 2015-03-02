#import "CombatScene.h"
#import "CombatLayer.h"
#import "MatchingLayer.h"

static NSString *const CHARACTER_DIED_NOTIFICATION =
    @"CharacterDidDieNotification";

static const int COUNT_DOWN_MAX = 10;

@implementation CombatScene {
  MatchingLayer *_matchingLayer;
  CombatLayer *_combatLayer;

  CCLabelTTF *_heroHealth, *_enemyHealth;
  CCLabelTTF *_winLabel, *_loseLabel;
  CCLabelTTF *_countDown;
  
  int _countDownTime;
}

# pragma mark Set up

- (void)didLoadFromCCB {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(gameOverForSide:)
                                               name:CHARACTER_DIED_NOTIFICATION
                                             object:nil];
  _countDownTime = COUNT_DOWN_MAX;
  [_countDown setString:[@(_countDownTime) stringValue]];
  _countDown.visible = YES;
  [self schedule:@selector(tick) interval:1];
}

- (void)replay {
  CCScene *scene = [CCBReader loadAsScene:@"CombatScene"];
  [[CCDirector sharedDirector] replaceScene:scene];
  [_matchingLayer reDeployBlocks];
}

# pragma mark Message coordinate

- (void)attackWithCharacter:(int)character withType:(int)type {
  [_combatLayer attackWithCharacter:character withType:type withStrength:20];
  _countDownTime = COUNT_DOWN_MAX + 1;
}

- (void)updateHealthPointsOn:(int)side withUpdate:(int)value {
  if (side == HERO_SIDE) {
    [_heroHealth setString:[NSString stringWithFormat:@"HP %d", value]];
  } else if (side == ENEMY_SIDE) {
    [_enemyHealth setString:[NSString stringWithFormat:@"HP %d", value]];
  }
}

- (void)gameOverForSide:(NSNotification *)notification {
  // stop interaction
  [self unschedule:@selector(tick)];
  _countDown.visible = NO;
  [_matchingLayer clearAllButtons];

  NSDictionary *resultDict = [notification userInfo];
  // side: -1 for left: hero, 1 for right: enemy
  int winSide = [[resultDict objectForKey:@"winSide"] intValue];
  if (winSide == HERO_SIDE) {
    // player wins
    NSLog(@"GameOver! You win!");
    CCNodeColor *layer = [CCNodeColor
                          nodeWithColor:[CCColor colorWithRed:100 green:100 blue:100 alpha:1]];
    [self addChild:layer z:-1];
    _winLabel.visible = YES;
  } else if (winSide == ENEMY_SIDE) {
    // player loses
    NSLog(@"GameOver! You lose");
    CCNodeColor *layer = [CCNodeColor
        nodeWithColor:[CCColor colorWithRed:255 green:0 blue:0 alpha:1]];
    [self addChild:layer z:-1];
    _loseLabel.visible = YES;
  }
}

#pragma mark Others

- (void)tick {
  if (_countDownTime == 0) {
    [self attackWithCharacter:ENEMY_SIDE withType:0];
    [_matchingLayer reDeployBlocks];
  } else {
    _countDownTime -= 1;
    [_countDown setString:[@(_countDownTime) stringValue]];
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
