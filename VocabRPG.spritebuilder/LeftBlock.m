//
//  LeftBlock.m
//  VocabRPG
//
//  Created by Junjia He on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "LeftBlock.h"

@implementation LeftBlock {
  CCButton *_button;
}

- (void)didLoadFromCCB {
  CCLabelBMFont *label =
      [CCLabelBMFont labelWithString:@"junjiah"
                             fntFile:@"Helvetica"
                               width:_button.contentSize.width
                           alignment:CCTextAlignmentCenter];
  label.position = ccp(0.5, 0.5);
  label.positionType = CCPositionTypeNormalized;
  [_button addChild:label];
}

@end
