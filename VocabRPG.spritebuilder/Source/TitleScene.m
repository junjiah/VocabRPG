//
//  TitleScene.m
//  VocabRPG
//
//  Created by Junjia He on 4/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "TitleScene.h"
#import "AppDelegate.h"
#import "CombatLayer.h"

@implementation TitleScene {
  CCNode *_slotContainer;

  CCButton *_newGameButton, *_continueButton, *_loadButton;
}

- (id)init {
  if (self = [super init]) {
    self.userInteractionEnabled = TRUE;
  }
  return self;
}

- (void)didLoadFromCCB {
  // disable 'continue' button if no recorded data
  if (![[NSUserDefaults standardUserDefaults] objectForKey:@"currentSaveSlot"])
    _continueButton.enabled = NO;

  // make them have roughly the same size
  _continueButton.preferredSize = _newGameButton.contentSize;
  _loadButton.preferredSize = _newGameButton.contentSize;
}

- (void)startNewGame {

  [self toggleButtonVisibility];

  // when button pressed, start new game!
  void (^newGameAction)(id) = ^void(id sender) {
    NSString *slotString = ((CCButton *)sender).name;

    // overwrite current slot
    [[NSUserDefaults standardUserDefaults] setValue:slotString
                                             forKey:@"currentSaveSlot"];
    // handle saves
    NSMutableArray *saves;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"saves"]) {
      saves = [NSMutableArray arrayWithObjects:[NSMutableDictionary dictionary],
                                               [NSMutableDictionary dictionary],
                                               [NSMutableDictionary dictionary],
                                               nil];
      [[NSUserDefaults standardUserDefaults] setValue:saves forKey:@"saves"];
    }

    // get the writable proxy
    saves = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"saves"];

    NSMutableDictionary *savedDataCopy = [NSMutableDictionary
                                          dictionaryWithDictionary:saves[slotString.intValue]];
    [savedDataCopy setValue:@"LEVEL 1" forKey:@"progress"];
    [savedDataCopy setValue:@(0) forKey:@"played_time"];
    
    saves[slotString.intValue] = savedDataCopy;
    [[NSUserDefaults standardUserDefaults] synchronize];

    // nullify coredata-relevant data for reloading
    AppController *appDelegate =
        (AppController *)[[UIApplication sharedApplication] delegate];
    appDelegate.persistentStoreCoordinator = nil;
    appDelegate.managedObjectContext = nil;
    
    // clear the core data `table`
    [appDelegate clearStore:slotString];

    // play!
    [self proceedGame:@"LEVEL 1"];
  };

  CCNode *slots = [self prepareSlotAt:_newGameButton.positionInPoints
                           withAction:newGameAction];

  [self addChild:slots];
}

- (void)loadGame {
  [self toggleButtonVisibility];

  // when button pressed, load game
  void (^loadAction)(id) = ^void(id sender) {
    NSString *title = ((CCButton *)sender).title;
    if ([title isEqualToString:@"Empty Slot"]) {
      // cannot load
      return;
    }

    NSString *slotString = ((CCButton *)sender).name;
    [[NSUserDefaults standardUserDefaults] setValue:slotString
                                             forKey:@"currentSaveSlot"];

    // read current progress
    NSDictionary *savedData =
        [[[NSUserDefaults standardUserDefaults] arrayForKey:@"saves"]
            objectAtIndex:[slotString intValue]];
    NSString *progress = [savedData objectForKey:@"progress"];

    // nullify coredata-relevant data for reloading
    AppController *appDelegate =
        (AppController *)[[UIApplication sharedApplication] delegate];
    appDelegate.persistentStoreCoordinator = nil;
    appDelegate.managedObjectContext = nil;

    // play!
    [self proceedGame:progress];
  };

  CCNode *slots =
      [self prepareSlotAt:_loadButton.positionInPoints withAction:loadAction];

  [self addChild:slots];
}

- (void)continueGame {
  NSString *currentSaveSlot =
      [[NSUserDefaults standardUserDefaults] stringForKey:@"currentSaveSlot"];
  NSDictionary *savedData =
      [[[NSUserDefaults standardUserDefaults] arrayForKey:@"saves"]
          objectAtIndex:[currentSaveSlot intValue]];
  NSString *progress = [savedData objectForKey:@"progress"];
  [self proceedGame:progress];
}

/**
 *  A helper function to go directly into a specified level.
 *
 *  @param progress A string indicating the desired level, starting from 'LEVEL
 *1'
 */
- (void)proceedGame:(NSString *)progress {
  // parse the progress string, since only the last part indicates the level
  int level = [[progress componentsSeparatedByString:@" "][1] intValue] - 1;
  [CombatLayer setStartLevel:level];

  CCScene *scene = [CCBReader loadAsScene:@"CombatScene"];
  [[CCDirector sharedDirector]
        replaceScene:scene
      withTransition:[CCTransition transitionCrossFadeWithDuration:1]];
}

- (CCNode *)prepareSlotAt:(CGPoint)position withAction:(void (^)(id))action {
  int width = [self boundingBox].size.width * 0.35;
  int height = [self boundingBox].size.height * 0.25;

  // build a node around the button
  _slotContainer = [CCNode node];
  _slotContainer.anchorPoint = ccp(0.5f, 0.5f);
  _slotContainer.positionInPoints = _newGameButton.positionInPoints;

  // set up the background
  CCSprite *slotBackground = [CCSprite spriteWithImageNamed:@"slot.png"];
  slotBackground.anchorPoint = ccp(0.5f, 0.5f);
  float backgroundScaleX = width / slotBackground.contentSize.width,
        backgroundScaleY = height / slotBackground.contentSize.height;
  [slotBackground setScaleX:backgroundScaleX];
  [slotBackground setScaleY:backgroundScaleY];

  // put 3 buttons
  float firstCenter = 0.18f;
  float centerPosition[] = {1 - firstCenter, 0.5f, firstCenter};

  // check saves available or not
  NSArray *saves =
      [[NSUserDefaults standardUserDefaults] objectForKey:@"saves"];

  for (int i = 0; i < 3; ++i) {
    CCButton *button = [CCButton buttonWithTitle:@"Empty Slot"];
    button.name = [NSString stringWithFormat:@"%d", i];
    button.anchorPoint = ccp(0.5f, 0.5f);
    button.positionType = CCPositionTypeNormalized;
    button.position = ccp(0.5f, centerPosition[i]);
    [button setScaleX:1 / backgroundScaleX];
    [button setScaleY:1 / backgroundScaleY];

    // assign size according to the position
    if (i == 1)
      button.preferredSize = CGSizeMake(width, height * (1 - firstCenter * 4));
    else
      button.preferredSize = CGSizeMake(width, height * 2 * firstCenter);

    // register passed action
    button.block = action;
    // read data for display
    if (saves) {
      NSDictionary *d = saves[i];
      NSString *progress = [d objectForKey:@"progress"];
      if (progress)
        button.title = progress;
    }
    [slotBackground addChild:button];
  }

  [_slotContainer addChild:slotBackground];
  return _slotContainer;
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  [_slotContainer removeFromParent];
  if (!_newGameButton.visible)
    [self toggleButtonVisibility];
}

- (void)toggleButtonVisibility {
  _newGameButton.visible = !_newGameButton.visible;
  _continueButton.visible = !_continueButton.visible;
  _loadButton.visible = !_loadButton.visible;
}

@end
