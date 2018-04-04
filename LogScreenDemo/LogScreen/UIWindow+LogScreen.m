

#import "UIWindow+LogScreen.h"
#import "LogScreen.h"

@implementation UIWindow (LogScreen)


- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    //监听摇一摇事件
    if (event.type == UIEventSubtypeMotionShake) {
        [[LogScreen getInstance] changeVisible];
    }
}


@end
