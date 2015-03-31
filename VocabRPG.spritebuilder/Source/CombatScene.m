#import "CombatScene.h"
#import "CombatLayer.h"
#import "MatchingLayer.h"
#import "Glossary.h"

static NSString *const CHARACTER_DIED_NOTIFICATION =
    @"CharacterDidDieNotification";

static const int COUNT_DOWN_MAX = 10;

@implementation CombatScene {
  MatchingLayer *_matchingLayer;
  CombatLayer *_combatLayer;

  CCLabelTTF *_heroHealth, *_enemyHealth;
  CCLabelTTF *_winLabel, *_loseLabel;
  CCLabelTTF *_countDown;

  CCButton *_glossary;
  
  int _countDownTime;
}

#pragma mark Set up or button callback

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
  [_matchingLayer redeployBlocks];
}

- (void)displayGlossary {
  CCScene *glossaryScene = [CCScene new];
  
  // add a background
  int width = [self boundingBox].size.width;
  int height = [self boundingBox].size.height;
  CCSprite *colorBackground = [CCSprite spriteWithImageNamed:@"wood.png"];
  float backgroundScaleX = width / colorBackground.contentSize.width,
        backgroundScaleY = height / colorBackground.contentSize.height;
  [colorBackground setScaleX:backgroundScaleX];
  [colorBackground setScaleY:backgroundScaleY];
  
  colorBackground.userInteractionEnabled = NO;
  colorBackground.positionType = CCPositionTypeNormalized;
  colorBackground.anchorPoint = ccp(0.5f, 0.5f);
  colorBackground.position = ccp(0.5f, 0.5f);

  [glossaryScene addChild:colorBackground];
  
  Glossary *glossary = [Glossary new];
  CCTableView* glossaryTable = [CCTableView new];
  glossaryTable.bounces = YES;
  glossaryTable.positionType = CCPositionTypeNormalized;
  glossaryTable.anchorPoint = ccp(0.5f, 0.5f);
  glossaryTable.position = ccp(0.5f, 0.5f);
  glossaryTable.contentSize = CGSizeMake(1, 0.9f);
  
  glossaryTable.dataSource = glossary;
  [glossaryScene addChild:glossaryTable];
  
  CCButton *backButton = [CCButton buttonWithTitle:@"Back"];
  backButton.positionType = CCPositionTypeNormalized;
  backButton.position = ccp(0.05f, 0.02f);
  backButton.block = ^(id sender) {
    [[CCDirector sharedDirector] popSceneWithTransition:[CCTransition transitionFadeWithColor:[CCColor blackColor] duration:0.5]];
  };
  [glossaryScene addChild:backButton];
  
  [[CCDirector sharedDirector] pushScene:glossaryScene withTransition:[CCTransition transitionCrossFadeWithDuration:0.5]];
}

#pragma mark Message coordinate

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

# pragma mark Notification callback

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
    _glossary.userInteractionEnabled = NO;
    CCNodeColor *layer = [CCNodeColor
        nodeWithColor:[CCColor colorWithRed:100 green:100 blue:100 alpha:1]];
    [self addChild:layer z:-1];

    _winLabel.visible = YES;
    // to next level
    [_combatLayer goToNextLevel];
    // wait 4 seconds then reset game
    id delay = [CCActionDelay actionWithDuration:4];
    id cleanLayer = [CCActionCallBlock actionWithBlock:^(void) {
      _winLabel.visible = NO;
      [self removeChild:layer];
      [_matchingLayer redeployBlocks];
      [self schedule:@selector(tick) interval:1];
      _countDown.visible = YES;
      _glossary.userInteractionEnabled = YES;
    }];
    [self runAction:[CCActionSequence actions:delay, cleanLayer, nil]];
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
    [_matchingLayer redeployBlocks];
  } else {
    _countDownTime -= 1;
    [_countDown setString:[@(_countDownTime) stringValue]];
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
