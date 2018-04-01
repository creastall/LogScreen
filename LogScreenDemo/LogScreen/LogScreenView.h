

#import <UIKit/UIKit.h>

@interface LogScreenView : UIView

- (void)updateLog:(NSString *)logText index:(int)index scrollToBottom:(bool)bottom;

@property (nonatomic, strong) void(^indexBlock)(NSInteger index);

@property (nonatomic, strong) void(^CleanButtonIndexBlock)(NSInteger index);

@property (nonatomic, strong) void(^closeBlock)();

@property (nonatomic, strong) UITextView *logTextView;

@end
