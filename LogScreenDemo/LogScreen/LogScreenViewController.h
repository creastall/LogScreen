//
//  LogScreenViewController.h
//  LogScreenDemo
//
//  Created by downjoy on 2018/4/2.
//  Copyright © 2018年 downjoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogScreenViewController : UIViewController

/**
 更新当前显示的日志

 @param logText 将要显示的日志信息
 @param index 值为0表示普通日志，值为1表示奔溃日志
 @param bottom 是否自动滚动到底部
 */
- (void)updateLog:(NSString *)logText index:(int)index scrollToBottom:(bool)bottom;

/**
 监听切换segment事件的，并且回传index
 */
@property (nonatomic, strong) void(^indexBlock)(NSInteger index);

/**
 监听clean按钮事件，并且回传当前的index
 */
@property (nonatomic, strong) void(^CleanButtonIndexBlock)(NSInteger index);

/**
 监听关闭按钮事件
 */
@property (nonatomic, strong) void(^closeBlock)();

/**
 监听滑动停止事件，主要用来更新日志显示内容
 */
@property (nonatomic, strong) void(^scrollViewDidEndDecelerating)();

/**
 监听搜索框文字变化事件
 */
@property (nonatomic, strong) void(^searchTextFieldDidChangeValue)(NSString* str);

/**
 监听搜索事件和向上和向下查找
 */
@property (nonatomic, strong) int(^textFieldShouldReturnBlock)(int index);

/**
 显示日志的控件
 */
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

/**
 切换普通日志和奔溃的segment控件
 */
@property (weak, nonatomic) IBOutlet UISegmentedControl *logSwitch;

/**
 保存所有搜索结果，数组里面保存的是word出现的位置的起点location
 */
@property(strong,nonatomic) NSMutableArray* searchResult;

/**
 搜索框里面的值
 */
@property(strong,nonatomic) NSString* searchStr;


/**
 搜索所有日志，并且保存搜索结果

 @param text 将要搜索的字符
 @param btn 是否点击了搜索按钮来搜索的
 */
-(void) setSearchLabelNumIntext: (NSString*)text btnSearch:(bool)btn;

/**
 日志自动添加的时候，搜索新增加的日志中是否有搜索框字符，并且更新搜索结果

 @param text 新增加的日志
 */
-(void) addSearchLabelNumInaddedtext: (NSString*)text;

@end
