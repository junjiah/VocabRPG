//
//  RightBlock.m
//  VocabRPG
//
//  Created by Junjia He on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "RightBlock.h"

@implementation RightBlock {
  CCButton *_button;
}

- (void)didLoadFromCCB {
  CCLabelBMFont *label =
      [CCLabelBMFont labelWithString:@"junjiah"
                             fntFile:@"Animal2.ttf"
                               width:_button.contentSize.width
                           alignment:CCTextAlignmentCenter];
  label.position = ccp(0.5, 0.5);
  label.positionType = CCPositionTypeNormalized;
  [_button addChild:label];
}

@end
