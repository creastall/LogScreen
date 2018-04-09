

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface LogScreen : NSObject<UITextViewDelegate>


+ (instancetype)getInstance;

- (void) logRecordMaxSize:(int)maxSize;

- (void) changeVisible;

@end
