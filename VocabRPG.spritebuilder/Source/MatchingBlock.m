//
//  Block.m
//  VocabRPG
//
//  Created by Junjia He on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "MatchingBlock.h"

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
  id actionAppear = [CCActionShow action];
  id delay = [CCActionDelay actionWithDuration:1.f];
  [_button runAction:[CCActionSequence actions:delay, actionAppear, nil]];
}

- (void)shake {

}

@end
