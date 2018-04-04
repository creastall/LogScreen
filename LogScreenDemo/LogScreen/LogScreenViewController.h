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

@property (nonatomic, strong) void(^searchTextFieldDidChangeValue)(NSString* str);

@property (nonatomic, strong) int(^textFieldShouldReturnBlock)(int index);

@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *logSwitch;

@property(strong,nonatomic) NSMutableArray* searchResult;

//搜索输入框每次检查到变动的时候更新这个值
@property(strong,nonatomic) NSString* searchStr;


-(void) setSearchLabelNumIntext: (NSString*)text btnSearch:(bool)btn;

-(void) addSearchLabelNumInaddedtext: (NSString*)text;

@end
