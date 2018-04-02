//
//  LogScreenViewController.h
//  LogScreenDemo
//
//  Created by downjoy on 2018/4/2.
//  Copyright © 2018年 downjoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogScreenViewController : UIViewController

- (void)updateLog:(NSString *)logText index:(int)index scrollToBottom:(bool)bottom;

@property (nonatomic, strong) void(^indexBlock)(NSInteger index);

@property (nonatomic, strong) void(^CleanButtonIndexBlock)(NSInteger index);

@property (nonatomic, strong) void(^closeBlock)();

@property (nonatomic, strong) void(^scrollViewDidEndDecelerating)();

@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@end
