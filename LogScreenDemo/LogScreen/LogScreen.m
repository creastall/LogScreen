

#import "LogScreen.h"
#import "LogScreenView.h"

#define LogFileName @"LogScreenInfo.log"
#define CarshFileName @"DCCrashInfo.log"

static int const bufferMaxSize = 6000;
static int const clearbufferSize = 1000;

@interface LogScreen()

@property (nonatomic, copy) NSString *crashInfoString;

@property (nonatomic, strong) LogScreenView *logView;

@property (nonatomic, assign) NSInteger index;

@property(strong,nonatomic) NSMutableString* currentShowLog;

@property(strong,nonatomic) NSMutableString* topShowLog;

@property(strong,nonatomic) NSMutableString* bottomShowLog;

@property(assign,nonatomic) int outFd;

@property(assign,nonatomic) int errFd;

@end

@implementation LogScreen

+ (instancetype)getInstance {
    static LogScreen *log = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        log = [[LogScreen alloc] init];
        log.currentShowLog = [[NSMutableString alloc] init];
        log.topShowLog = [[NSMutableString alloc] init];
        log.bottomShowLog = [[NSMutableString alloc] init];
        log.logView = nil;
        [log readCarshInfo];
        
    });
    return log;
}


- (void)changeVisible {
    !self.logView.hidden ? [self hideLogView] : [self showLogView];
}

- (void)showLogView {
    
    [UIView animateWithDuration:0.4 animations:^{
        self.logView.alpha = 1.0f;
    }];
    
    self.logView.hidden = NO;
    
    self.logView.indexBlock = ^(NSInteger index) {
        LogScreen* logm = [LogScreen getInstance];
        logm.index = index;
        [logm updateUIWithBottom:true];
    };
    //清除所有当前日志，包括缓冲日志
    self.logView.CleanButtonIndexBlock = ^(NSInteger index) {
        LogScreen* logm = [LogScreen getInstance];
        logm.index = index;
        if (logm.index == 0) {
            [logm.topShowLog setString:@""];
            [logm.currentShowLog setString:@""];
            [logm.bottomShowLog setString:@""];
            [logm updateUIWithBottom:true];
        }else if (logm.index == 1) {
            [[NSFileManager defaultManager]removeItemAtPath:[logm loadPathWithName:CarshFileName] error:nil];
        }
    };
    self.logView.closeBlock = ^(){
        [[LogScreen getInstance] changeVisible];
    };
}

- (void)hideLogView {
    [UIView animateWithDuration:0.4 animations:^{
        self.logView.alpha = 0.0f;
    }];
    self.logView.hidden = YES;
}

//启动标准输出定向
- (void)logRecord{
    //注册奔溃函数
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    //记录标准输出及错误流原始文件描述符
    self.outFd = dup(STDOUT_FILENO);
    self.errFd = dup(STDERR_FILENO);
    stdout->_flags = 10;
    NSPipe *outPipe = [NSPipe pipe];
    NSFileHandle *pipeOutHandle = [outPipe fileHandleForReading];
    dup2([[outPipe fileHandleForWriting] fileDescriptor], STDOUT_FILENO);
    [pipeOutHandle readInBackgroundAndNotify];
    
    stderr->_flags = 10;
    NSPipe *errPipe = [NSPipe pipe];
    NSFileHandle *pipeErrHandle = [errPipe fileHandleForReading];
    dup2([[errPipe fileHandleForWriting] fileDescriptor], STDERR_FILENO);
    [pipeErrHandle readInBackgroundAndNotify];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redirectOutNotificationHandle:) name:NSFileHandleReadCompletionNotification object:pipeOutHandle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redirectErrNotificationHandle:) name:NSFileHandleReadCompletionNotification object:pipeErrHandle];
}
//还原标准输出定向
-(void)recoverStandardOutput{
    dup2(self.outFd, STDOUT_FILENO);
    dup2(self.errFd, STDERR_FILENO);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//从打印日志触发的事件
-(void) dealLog:(NSString*)log{
    CGFloat offsetY = self.logView.logTextView.contentOffset.y;
    CGFloat height = self.logView.logTextView.contentSize.height;
    CGFloat boundsheight = CGRectGetHeight(self.logView.bounds);
    if (height >= (offsetY + boundsheight)){
        //浏览模式
        if (self.currentShowLog.length < bufferMaxSize) {
            [self.currentShowLog appendString:log];
            if (self.currentShowLog.length > bufferMaxSize) {
                NSString* cutStr = [self.currentShowLog substringToIndex: self.currentShowLog.length - bufferMaxSize];
                [self.topShowLog appendString:cutStr];
                [self.currentShowLog deleteCharactersInRange:NSMakeRange(0,self.currentShowLog.length - bufferMaxSize)];
            }
        }else{
            [self.bottomShowLog appendString:log];
        }
        
    }
    else{
        //自动滚动模式
        if (self.bottomShowLog.length == 0) {
            [self.currentShowLog appendString:log];
            if (self.currentShowLog.length > bufferMaxSize) {
                NSString* cutStr = [self.currentShowLog substringToIndex: self.currentShowLog.length - bufferMaxSize];
                [self.topShowLog appendString:cutStr];
                [self.currentShowLog deleteCharactersInRange:NSMakeRange(0,self.currentShowLog.length - bufferMaxSize)];
            }
        }
        else{
            [self.bottomShowLog appendString:log];
            if (self.bottomShowLog.length > clearbufferSize) {
                NSString* bottomtopcut = [self.bottomShowLog substringToIndex: clearbufferSize];
                [self.currentShowLog appendString:bottomtopcut];
                [self.bottomShowLog deleteCharactersInRange:NSMakeRange(0, clearbufferSize)];
                NSString* currenttopcut = [self.currentShowLog substringToIndex: clearbufferSize];
                [self.topShowLog appendString:currenttopcut];
                [self.currentShowLog deleteCharactersInRange:NSMakeRange(0, clearbufferSize)];
            }
            else{
                [self.currentShowLog appendString:self.bottomShowLog];
                [self.bottomShowLog setString:@""];
                NSString* cutStr = [self.currentShowLog substringToIndex: self.bottomShowLog.length];
                [self.topShowLog appendString:cutStr];
                [self.currentShowLog deleteCharactersInRange:NSMakeRange(0,self.bottomShowLog.length)];
            }
        }
        [self updateUIWithBottom:true];
    }
}

// 重定向之后的NSLog输出
- (void)redirectOutNotificationHandle:(NSNotification *)nf{
    
    NSData *data = [[nf userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self dealLog:str];
    // YOUR CODE HERE...  保存日志并上传或展示
    
    [[nf object] readInBackgroundAndNotify];
}

// 重定向之后的错误输出
- (void)redirectErrNotificationHandle:(NSNotification *)nf{
    
    NSData *data = [[nf userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // YOUR CODE HERE...  保存日志并上传或展示
    [self dealLog:str];
    
    [[nf object] readInBackgroundAndNotify];
}

- (LogScreenView *)logView {
    if (!_logView) {
        _logView = [[LogScreenView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _logView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [[UIApplication sharedApplication].keyWindow addSubview:_logView];
        _logView.logTextView.delegate = self;
        _logView.hidden = YES;
        _logView.alpha = 0.0f;
    }
    return _logView;
}

void UncaughtExceptionHandler(NSException *exception) {
    
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    NSString *crashInfo = [NSString stringWithFormat:@"Crash date: %@ \nNexception type: %@ \nCrash reason: %@ \nStack symbol info: %@ \n",[[LogScreen getInstance] getCurrentDate], name, reason, arr];
    [[LogScreen getInstance] saveCrashInfo:crashInfo];
}

- (void)saveCrashInfo:(NSString *)crashInfo {
    
    if (self.crashInfoString) {
        self.crashInfoString = [self.crashInfoString stringByAppendingString:crashInfo];
    }else {
        self.crashInfoString = crashInfo;
    }
    
    [self.crashInfoString writeToFile:[self loadPathWithName:CarshFileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *)readCarshInfo {
    
    NSData *crashData = [NSData dataWithContentsOfFile: [self loadPathWithName:CarshFileName]];
    NSString *crashText = [[NSString alloc]initWithData:crashData encoding:NSUTF8StringEncoding];
    self.crashInfoString = crashText;
    return crashText;
}


- (NSString *)loadPathWithName:(NSString *)fileName {
    NSString *documentDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentDirPath stringByAppendingPathComponent:fileName];
    return path;
}

- (NSDate *)getCurrentDate {
    NSDate *now = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger seconds = [zone secondsFromGMTForDate:now];
    NSDate *newDate = [now dateByAddingTimeInterval:seconds];
    return newDate;
}
#pragma mark UIScrollView implementation
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat offsetY = self.logView.logTextView.contentOffset.y;
    CGFloat height = self.logView.logTextView.contentSize.height;
    CGFloat boundsheight = CGRectGetHeight(self.logView.bounds);

    if (height >= (offsetY + boundsheight)){
        if (offsetY == 0) {
            //向下滑动，直到滑不动了就调用这个函数，到了top了
            if (self.topShowLog.length >0) {
                if (self.topShowLog.length > clearbufferSize) {
                    
                    NSString* currentbottomcut = [self.currentShowLog substringFromIndex:self.currentShowLog.length - clearbufferSize];
                    [self.currentShowLog deleteCharactersInRange:NSMakeRange(self.currentShowLog.length - clearbufferSize,clearbufferSize)];
                    [self.bottomShowLog insertString:currentbottomcut atIndex:0];
                    
                    NSString* topbottomcut = [self.topShowLog substringFromIndex:self.topShowLog.length - clearbufferSize];
                    [self.currentShowLog insertString:topbottomcut atIndex:0];
                    [self.topShowLog deleteCharactersInRange:NSMakeRange(self.topShowLog.length - clearbufferSize,clearbufferSize)];
                }
                else{
                    NSString* currentbottomcut = [self.currentShowLog substringFromIndex:self.currentShowLog.length - self.topShowLog.length];
                    [self.currentShowLog deleteCharactersInRange:NSMakeRange(self.currentShowLog.length - self.topShowLog.length,self.topShowLog.length)];
                    [self.bottomShowLog insertString:currentbottomcut atIndex:0];
                    
                    [self.currentShowLog insertString:self.topShowLog atIndex:0];
                    [self.topShowLog setString:@""];
                }
                [self updateUIWithBottom:false];
            }
        }
    }else{
        //向上滑动，直到滑不动了就调用这个函数，到了bottom了
        if (self.bottomShowLog.length > 0) {
            if (self.bottomShowLog.length >clearbufferSize) {
                NSString* currenttopcut = [self.currentShowLog substringToIndex:clearbufferSize];
                [self.currentShowLog deleteCharactersInRange:NSMakeRange(0,clearbufferSize)];
                [self.topShowLog appendString:currenttopcut];
                NSString* bottomtopcut = [self.bottomShowLog substringToIndex:clearbufferSize];
                [self.currentShowLog appendString:bottomtopcut];
                [self.bottomShowLog deleteCharactersInRange:NSMakeRange(0,clearbufferSize)];
            }
            else{
                NSString* currenttopcut = [self.currentShowLog substringToIndex:self.bottomShowLog.length];
                [self.currentShowLog deleteCharactersInRange:NSMakeRange(0,self.bottomShowLog.length)];
                [self.topShowLog appendString:currenttopcut];
                [self.currentShowLog appendString:self.bottomShowLog];
                [self.bottomShowLog setString:@""];
            }
            [self updateUIWithBottom:true];
        }
    }

}

-(void)updateUIWithBottom:(bool)bottom{
    //更新ui
    if (self.index == 0) {
        [self.logView updateLog:self.currentShowLog  index: (int)self.index scrollToBottom:bottom];
        
    }else if (self.index == 1) {
        [self.logView updateLog:[self readCarshInfo] index: (int)self.index scrollToBottom:bottom];
    }
}

@end
