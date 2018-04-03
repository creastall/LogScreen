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

@property (weak, nonatomic) IBOutlet UIButton *lastBtn;

@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property(assign,nonatomic) int searchResultShowIndex;



@property (weak, nonatomic) IBOutlet UILabel *searchNum;
@property (weak, nonatomic) IBOutlet UITextField *searchText;
@property(assign,nonatomic) int allSearchLogLength;

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
    
    self.lastBtn.layer.cornerRadius = 5.0f;
    self.lastBtn.layer.borderWidth = 1.0f;
    self.lastBtn.layer.borderColor = [UIColor colorWithRed:12/255.0 green:95/255.0 blue:250/255.0 alpha:1.0].CGColor;
    
    self.nextBtn.layer.cornerRadius = 5.0f;
    self.nextBtn.layer.borderWidth = 1.0f;
    self.nextBtn.layer.borderColor = [UIColor colorWithRed:12/255.0 green:95/255.0 blue:250/255.0 alpha:1.0].CGColor;
    
    
    [self.searchText addTarget:self action:@selector(searchTextFieldDidChangeValue:) forControlEvents:UIControlEventEditingChanged];
    
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
-(void)lookUpSelectedWord{
    if (self.searchResultShowIndex >= 0 && self.searchResultShowIndex < self.searchResult.count) {
        int startLoction = -1;
        if (self.searchText.text.length>0) {
            if (self.textFieldShouldReturnBlock) {
                startLoction = self.textFieldShouldReturnBlock(self.searchResultShowIndex);
            }
            if (self.searchResult.count>0) {
                if (startLoction >= 0) {
                    NSRange range = NSMakeRange(startLoction, self.searchStr.length);
                    [self selectAndVisibleWordWithRange:range];
                    self.searchNum.text = [NSString stringWithFormat:@"%d/%d",self.searchResultShowIndex+1,self.searchResult.count];
                }
            }
        }
    }
}
- (IBAction)lastClick:(id)sender {
    if (self.searchResultShowIndex > 0) {
        self.searchResultShowIndex = self.searchResultShowIndex - 1;
        [self lookUpSelectedWord];
    }
    else if(self.searchResultShowIndex == 0){
        [self lookUpSelectedWord];
    }
}
- (IBAction)nextClick:(id)sender {
    if (self.searchResultShowIndex < self.searchResult.count - 1) {
        self.searchResultShowIndex = self.searchResultShowIndex + 1;
        [self lookUpSelectedWord];

    }
    else if(self.searchResultShowIndex == 0){
        [self lookUpSelectedWord];
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
    [self.searchResult removeAllObjects];
    self.searchText.text = @"";
    self.searchNum.text = @"";
}

-(void) selectAndVisibleWordWithRange:(NSRange)range{
    if(![self.logTextView isFirstResponder]){
        [self.logTextView becomeFirstResponder];
    }
    self.logTextView.selectedRange = range;
    [self.logTextView scrollRangeToVisible:range];
}

-(NSMutableArray*)search:(NSString*)word in:(NSString*)src{
    
    NSMutableArray* ret = [[NSMutableArray alloc] init];
    if (word.length > 0) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:word options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matches = [regex matchesInString:src options:0 range:NSMakeRange(0, src.length)];
        for(NSTextCheckingResult *result in [matches objectEnumerator]){
            NSRange matchRange = [result range];
            [ret addObject: [NSNumber numberWithInteger:matchRange.location]];
        }
    }
    return ret;
}
//在text（这个是所有要搜索的日志）中搜索self.searchStr然后更新搜索结果到self.searchResult和self.searchNum
-(void) setSearchLabelNumIntext: (NSString*)text btnSearch:(bool)btn{
    if (text !=nil && text.length>0) {
        //更新所有日志的长度
        self.allSearchLogLength = text.length;
        self.searchResult = [self search:self.searchStr in:text];
        if (self.searchResult.count>0) {
            self.searchNum.text = [NSString stringWithFormat:@"%d",self.searchResult.count];
        }
        else{
            self.searchNum.text = @"0";
        }
        if (self.searchStr.length == 0) {
            self.searchNum.text = @"";
        }
    }
}
//在text(这个是新添加的日志)中搜索self.searchStr然后更新搜索结果到self.searchResult和self.searchNum
-(void) addSearchLabelNumInaddedtext: (NSString*)text{
    if (text !=nil && text.length>0) {
        NSMutableArray* tmp= [self search:self.searchStr in:text];
        if (tmp.count>0) {
            //更新搜索结果到数组
            for (NSNumber* item in tmp) {
                NSNumber* addresult = [[NSNumber alloc] initWithInt:self.allSearchLogLength+item.intValue];
                [self.searchResult addObject:addresult];
            }
            if (self.searchNum.text.length > 0) {
                NSRange range = [self.searchNum.text rangeOfString:@"/"];
                //没有找到/，说明全是数字
                if (range.location == NSNotFound) {
                    NSInteger oldnum = self.searchNum.text.integerValue;
                    self.searchNum.text = [NSString stringWithFormat:@"%d",tmp.count+oldnum];
                }
                //找到了/,需要只更新后面的数字
                else{
                    //包含了/
                    NSString* before = [self.searchNum.text substringToIndex:range.location+1];
                    NSString* after = [self.searchNum.text substringFromIndex:range.location+1];
                    NSString* newnumstr = [NSString stringWithFormat:@"%@%d",before,tmp.count+after.intValue];
                    self.searchNum.text = newnumstr;
                }
                
            }
        }
    }
}

#pragma mark UIScrollView implementation
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == self.logTextView) {
        self.scrollViewDidEndDecelerating();
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == self.logTextView) {
        int a = 0;
    }
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    int a = 0;
    return YES;
}
#pragma mark UITextFieldDelegate implementation
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSString* str = textField.text;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSString* str = textField.text;
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    [self.searchResult removeAllObjects];
    return YES;
}

//点击了search按钮
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    self.searchStr = textField.text;
    [textField resignFirstResponder];
    int startLoction = -1;
    if (self.searchText.text.length>0) {
        if (self.textFieldShouldReturnBlock) {
            startLoction = self.textFieldShouldReturnBlock(0);
        }
        if (self.searchResult.count>0) {
            self.searchResultShowIndex = 0;
            //NSRange range = NSMakeRange(((NSNumber*)[self.searchResult firstObject]).unsignedIntegerValue, self.searchStr.length);
            if (startLoction >= 0) {
                NSRange range = NSMakeRange(startLoction, self.searchStr.length);
                [self selectAndVisibleWordWithRange:range];
                self.searchNum.text = [NSString stringWithFormat:@"%d/%d",1,self.searchResult.count];
            }
        }
    }

    
    return YES;
}

//监听搜索框输入变化
- (void)searchTextFieldDidChangeValue:(UITextField *)textField{
    self.searchStr = textField.text;
    //通过代理，代理出去
    if (self.searchTextFieldDidChangeValue) {
        self.searchTextFieldDidChangeValue(self.searchStr);
    }
}

@end
