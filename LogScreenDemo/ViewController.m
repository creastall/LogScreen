//
//  ViewController.m
//  LogScreenDemo
//
//  Created by downjoy on 2018/4/1.
//  Copyright © 2018年 downjoy. All rights reserved.
//

#import "ViewController.h"
#import "LogScreen.h"


@interface ViewController ()

@property(assign,atomic) int count;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

}



- (void)giveLog {
    self.count++;
    if (self.count > 300) {
        return;
    }
    NSLog(@"NSTimer count = %d",self.count);
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)test:(id)sender {
    [[LogScreen getInstance] changeVisible];
    self.count = 0;
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(giveLog) userInfo:nil repeats:YES];
}


@end
