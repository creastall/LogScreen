//
//  LogScreenViewController.m
//  LogScreenDemo
//
//  Created by downjoy on 2018/4/2.
//  Copyright © 2018年 downjoy. All rights reserved.
//

#import "LogScreenViewController.h"

@interface LogScreenViewController ()

@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *cleanBtn;


@end

@implementation LogScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.closeBtn.layer.cornerRadius = 5.0f;
    self.closeBtn.layer.borderWidth = 1.0f;
    self.closeBtn.layer.borderColor = [UIColor colorWithRed:12/255.0 green:95/255.0 blue:250/255.0 alpha:1.0].CGColor;
    
    self.cleanBtn.layer.cornerRadius = 5.0f;
    self.cleanBtn.layer.borderWidth = 1.0f;
    self.cleanBtn.layer.borderColor = [UIColor colorWithRed:12/255.0 green:95/255.0 blue:250/255.0 alpha:1.0].CGColor;
    
    self.logTextView.layoutManager.allowsNonContiguousLayout = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)switchClick:(UISegmentedControl *)sender {
    if (self.indexBlock) {
        self.indexBlock(sender.selectedSegmentIndex);
    }
}

- (void)updateLog:(NSString *)logText index:(int)index scrollToBottom:(bool)bottom{
    self.logTextView.text = logText;
    if (bottom) {
        [self.logTextView scrollRangeToVisible:NSMakeRange(self.logTextView.text.length, 1)];
    }
}

- (IBAction)closeClick:(id)sender {
    if (self.closeBlock) {
        self.closeBlock();
    }
}
- (IBAction)CleanClick:(id)sender {
    if (self.CleanButtonIndexBlock) {
        self.CleanButtonIndexBlock(self.logSwitch.selectedSegmentIndex);
    }
}

#pragma mark UIScrollView implementation
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.scrollViewDidEndDecelerating();
}

@end
