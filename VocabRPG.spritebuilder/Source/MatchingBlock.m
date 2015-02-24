//
//  Block.m
//  VocabRPG
//
//  Created by Junjia He on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "MatchingBlock.h"

static id rotateLeft, rotateRight, tintRed, appear;

@implementation MatchingBlock {
  CCButton *_button;
}

- (void)didLoadFromCCB {
  _button.zoomWhenHighlighted = YES;
}

- (void)setButtonName:(NSString *)name {
  _button.name = name;
}

- (void)setButtonTitle:(NSString *)buttonTitle {
  _button.title = buttonTitle;
}

- (void)clear {
  _button.visible = NO;
}

- (void)reappear {
  id delay = [CCActionDelay actionWithDuration:1.f];
  [_button runAction:[CCActionSequence actions:delay, appear, nil]];
}

- (void)disable {
  [_button stopAllActions];
  _button.visible = NO;
}

- (void)shakeOnView:(MatchingLayer *)view {
  NSMutableArray *actions =
      [NSMutableArray arrayWithObjects:[rotateLeft copy], [rotateRight copy],
                                       [tintRed copy], nil];
  if (view != nil) {
    id delay = [CCActionDelay actionWithDuration:0.5f];
    id callDeploy =
        [CCActionCallFunc actionWithTarget:view
                                  selector:@selector(reDeployBlocks)];
    [actions addObject:delay];
    [actions addObject:callDeploy];
  }
  [_button runAction:[CCActionSequence actionWithArray:actions]];
}

+ (void)initialize {
  rotateLeft = [CCActionRotateBy actionWithDuration:0.1f angle:30.f];
  rotateRight = [CCActionRotateBy actionWithDuration:0.1f angle:-30.f];
  tintRed = [CCActionTintBy actionWithDuration:0.3f red:255 green:0 blue:0];
  appear = [CCActionShow action];
}

@end
