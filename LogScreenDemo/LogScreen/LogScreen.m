

#import "LogScreen.h"
#import "LogScreenViewController.h"

#define LogFileName @"LogScreenInfo.log"
#define CarshFileName @"CrashInfo.log"

static int const bufferMaxSize = 8000;
static int const clearbufferSize = 4000;

@interface LogScreen()

@property (nonatomic, copy) NSString *crashInfoString;

@property (nonatomic, strong) LogScreenViewController *logViewVC;

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
        [log readCarshInfo];
        
    });
    return log;
}

- (LogScreenViewController*)logViewVC{
    if (!_logViewVC) {
        _logViewVC = [[UIStoryboard storyboardWithName:@"logView" bundle:nil] instantiateInitialViewController];
        _logViewVC.view.hidden = YES;
        _logViewVC.view.alpha = 0.0f;
        [[UIApplication sharedApplication].keyWindow addSubview:_logViewVC.view];
    }
    return _logViewVC;
}



- (void)changeVisible {
    !self.logViewVC.view.hidden ? [self hideLogView] : [self showLogView];
}

- (void)showLogView {
    
    [UIView animateWithDuration:0.4 animations:^{
        self.logViewVC.view.alpha = 1.0f;
    }];
    
    self.logViewVC.view.hidden = NO;
    
    self.logViewVC.indexBlock = ^(NSInteger index) {
        LogScreen* logm = [LogScreen getInstance];
        logm.index = index;
        if (index == 0) {
            [logm updateUIWithBottom:false];
        }
        else{
            [logm updateUIWithBottom:true];
        }
        
    };
    //清除所有当前日志，包括缓冲日志
    self.logViewVC.CleanButtonIndexBlock = ^(NSInteger index) {
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
    self.logViewVC.closeBlock = ^(){
        [[LogScreen getInstance] changeVisible];
    };
    
    self.logViewVC.scrollViewDidEndDecelerating = ^(){
        [[LogScreen getInstance] scrollViewDidEndDecelerating];
    };
    //搜索框有字符变化
    self.logViewVC.searchTextFieldDidChangeValue = ^(NSString* changedStr){
        NSMutableString* tmpsearch = [[NSMutableString alloc] init];
        [tmpsearch appendString:[LogScreen getInstance].topShowLog];
        [tmpsearch appendString:[LogScreen getInstance].currentShowLog];
        [tmpsearch appendString:[LogScreen getInstance].bottomShowLog];
        if (tmpsearch.length > 0) {
            [[LogScreen getInstance].logViewVC setSearchLabelNumIntext:tmpsearch btnSearch:false];
        }
    };
    //点击搜索按钮
    self.logViewVC.textFieldShouldReturnBlock = ^(int locIndex){
        NSMutableString* tmpsearch = [[NSMutableString alloc] init];
        [tmpsearch appendString:[LogScreen getInstance].topShowLog];
        [tmpsearch appendString:[LogScreen getInstance].currentShowLog];
        [tmpsearch appendString:[LogScreen getInstance].bottomShowLog];
        int startLocation = -1;
        if (tmpsearch.length > 0) {
            [[LogScreen getInstance].logViewVC setSearchLabelNumIntext:tmpsearch btnSearch:true];
            //显示搜索结果的第一个word在当前log上面
            NSMutableArray* searchResult = [LogScreen getInstance].logViewVC.searchResult;
            if (searchResult && searchResult.count > 0) {
                NSNumber* item = searchResult[locIndex];
                NSString* search = [LogScreen getInstance].logViewVC.searchStr;
                int blockShowNum = item.intValue + search.length - bufferMaxSize;
                if (blockShowNum <= 0) {
                    int extLogLength = bufferMaxSize;
                    if (tmpsearch.length < extLogLength) {
                        extLogLength = tmpsearch.length;
                    }
                    [[LogScreen getInstance].topShowLog setString:@""];
                    [[LogScreen getInstance].currentShowLog setString:@""];
                    [[LogScreen getInstance].currentShowLog appendString:[tmpsearch substringToIndex:extLogLength]];
                    [[LogScreen getInstance].bottomShowLog setString:@""];
                    [[LogScreen getInstance].bottomShowLog appendString:[tmpsearch substringFromIndex:extLogLength]];
                    startLocation = item.intValue;
                }
                else{
                    int numOfCleanBuffer = blockShowNum / clearbufferSize + 1;
                    
                    [[LogScreen getInstance].currentShowLog setString:@""];
                    NSString* tmpcurrentlog = [tmpsearch substringToIndex:bufferMaxSize];
                    //取出前bufferMaxSize个字符到currentShowLog中
                    [[LogScreen getInstance].currentShowLog appendString:tmpcurrentlog];
                    int otherCleanBufferLength = numOfCleanBuffer * clearbufferSize;
                    if (otherCleanBufferLength > tmpsearch.length - bufferMaxSize) {
                        otherCleanBufferLength = tmpsearch.length - bufferMaxSize;
                    }
                    NSString* tmpstr = [tmpsearch substringWithRange:NSMakeRange(bufferMaxSize, otherCleanBufferLength)];
                    //取出后面连续numOfCleanBuffer个clearbufferSize大小的字符串块,添加到currentShowLog中
                    [[LogScreen getInstance].currentShowLog appendString: tmpstr];
                    //计算现在currentShowLog的字符个数
                    int currentloglength = [LogScreen getInstance].currentShowLog.length;
                    NSString* tmpTopLog = [[LogScreen getInstance].currentShowLog substringToIndex:(currentloglength - bufferMaxSize)];
                    //取出前(currentloglength - bufferMaxSize)个字符，准备添加到topShowLog中
                    [[LogScreen getInstance].topShowLog setString:@""];
                    [[LogScreen getInstance].topShowLog appendString:tmpTopLog];
                    //删除currentShowLog前bufferMaxSize个字符
                    [[LogScreen getInstance].currentShowLog deleteCharactersInRange:NSMakeRange(0,(currentloglength - bufferMaxSize))];
                    [[LogScreen getInstance].bottomShowLog setString:@""];
                    NSString* tmpbottomlog = [tmpsearch substringFromIndex: bufferMaxSize + otherCleanBufferLength];
                    [[LogScreen getInstance].bottomShowLog appendString:tmpbottomlog];
                    startLocation = item.intValue - [LogScreen getInstance].topShowLog.length;
                }
                [[LogScreen getInstance] updateUIWithBottom:false];
            }
        }
        return startLocation;
    };
}

- (void)hideLogView {
    
    [UIView animateWithDuration:0.4 animations:^{
        self.logViewVC.view.alpha = 0.0f;
    }];
    self.logViewVC.view.hidden = YES;
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
    CGFloat offsetY = self.logViewVC.logTextView.contentOffset.y;
    CGFloat height = self.logViewVC.logTextView.contentSize.height;
    CGFloat boundsheight = CGRectGetHeight(self.logViewVC.view.bounds);
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
            //非搜索模式下，滚动当前显示
            if (self.logViewVC.searchResult.count == 0) {
                [self.currentShowLog appendString:log];
                if (self.currentShowLog.length > bufferMaxSize) {
                    NSString* cutStr = [self.currentShowLog substringToIndex: self.currentShowLog.length - bufferMaxSize];
                    [self.topShowLog appendString:cutStr];
                    [self.currentShowLog deleteCharactersInRange:NSMakeRange(0,self.currentShowLog.length - bufferMaxSize)];
                    
                }
            }
            //搜索模式下，不滚动当前显示
            else{
                [self.bottomShowLog appendString:log];
            }

            [self updateUIWithBottom:[LogScreen getInstance].logViewVC.searchStr.length==0];
        }
        else{
            [self.bottomShowLog appendString:log];
            if (self.logViewVC.logSwitch.selectedSegmentIndex == 0) {
                if (self.bottomShowLog.length > clearbufferSize) {
                    //下面代码的作用是，当还有日志持续输出时，从任意一个位置向上滑动到当前显示界面的底部，会出现一直循环到最底部
                    if (self.logViewVC.searchResult.count == 0) {
                        NSString* bottomtopcut = [self.bottomShowLog substringToIndex: clearbufferSize];
                        [self.currentShowLog appendString:bottomtopcut];
                        [self.bottomShowLog deleteCharactersInRange:NSMakeRange(0, clearbufferSize)];
                        NSString* currenttopcut = [self.currentShowLog substringToIndex: clearbufferSize];
                        [self.topShowLog appendString:currenttopcut];
                        [self.currentShowLog deleteCharactersInRange:NSMakeRange(0, clearbufferSize)];
                    }
                }
                else{
                    //非搜索模式下，滚动当前显示
                    if (self.logViewVC.searchResult.count == 0) {
                        [self.currentShowLog appendString:self.bottomShowLog];
                        [self.bottomShowLog setString:@""];
                        NSString* cutStr = [self.currentShowLog substringToIndex: self.bottomShowLog.length];
                        [self.topShowLog appendString:cutStr];
                        [self.currentShowLog deleteCharactersInRange:NSMakeRange(0,self.bottomShowLog.length)];
                    }
                }
            }
        }
//        [self updateUIWithBottom:[LogScreen getInstance].logViewVC.searchStr.length==0];
    }
    [self.logViewVC addSearchLabelNumInaddedtext:log];

    
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

- (void)scrollViewDidEndDecelerating{
    CGFloat offsetY = self.logViewVC.logTextView.contentOffset.y;
    CGFloat height = self.logViewVC.logTextView.contentSize.height;
    CGFloat boundsheight = CGRectGetHeight(self.logViewVC.view.bounds);

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
            
            [self updateUIWithBottom:false];
        }
    }

}

-(void)updateUIWithBottom:(bool)bottom{
    //更新ui
    if (self.index == 0) {
        [self.logViewVC updateLog:self.currentShowLog  index: (int)self.index scrollToBottom:bottom];
        
    }else if (self.index == 1) {
        [self.logViewVC updateLog:[self readCarshInfo] index: (int)self.index scrollToBottom:bottom];
    }
}

@end
