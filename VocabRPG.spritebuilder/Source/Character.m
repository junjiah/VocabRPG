#import "Character.h"

@implementation Character

- (void)didLoadFromCCB {
  self.position = ccp(115, 250);
  //    self.zOrder = DrawingOrderHero;
  self.physicsBody.collisionType = @"character";
}

- (void)flap {
  [self.physicsBody applyImpulse:ccp(0, 400.f)];
}

@end
