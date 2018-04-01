

#import "UIWindow+LogScreen.h"
#import "LogScreen.h"

@implementation UIWindow (LogScreen)

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventSubtypeMotionShake) {
        [[LogScreen getInstance] changeVisible];
    }
}


@end
