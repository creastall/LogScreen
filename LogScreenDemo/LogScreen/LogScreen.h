

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LogScreen : NSObject<UITextViewDelegate>


+ (instancetype)getInstance;


- (void) logRecord;


- (void) changeVisible;

@end
