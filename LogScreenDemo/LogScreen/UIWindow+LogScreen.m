

#import "UIWindow+LogScreen.h"
#import "LogScreen.h"

@implementation UIWindow (LogScreen)

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    //所有事件都触发注册日志, 注册过了就不再注册
    [[LogScreen getInstance] logRecordMaxSize:20000];
    //监听摇一摇事件
    if (event.type == UIEventSubtypeMotionShake) {
        [[LogScreen getInstance] changeVisible];
    }
}


@end
