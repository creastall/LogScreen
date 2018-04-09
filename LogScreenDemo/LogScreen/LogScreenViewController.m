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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *switchTopConstraintlandscape;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logTextViewToplandscape;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchTextLeftlandscape;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchToplandscape;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanBtnToplandscape;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeBtnToplandscape;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastBtnToplandscape;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextBtnToplandscape;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextBtnRightlandscape;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchNumToplandscape;

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
    
    self.searchText.layer.cornerRadius = 5.0f;
    self.searchText.layer.borderWidth = 1.0f;
    self.searchText.layer.borderColor = [UIColor colorWithRed:12/255.0 green:95/255.0 blue:250/255.0 alpha:1.0].CGColor;
    
    
    [self.searchText addTarget:self action:@selector(searchTextFieldDidChangeValue:) forControlEvents:UIControlEventEditingChanged];
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self setupViewForOrientation];
}

- (void)setupViewForOrientation{
     UIInterfaceOrientation oritentation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(oritentation)) {
        self.switchTopConstraintlandscape.priority = UILayoutPriorityDefaultLow;
        self.logTextViewToplandscape.priority = UILayoutPriorityDefaultLow;
        self.searchTextLeftlandscape.priority = UILayoutPriorityDefaultLow;
        self.searchToplandscape.priority = UILayoutPriorityDefaultLow;
        self.cleanBtnToplandscape.priority = UILayoutPriorityDefaultLow;
        self.closeBtnToplandscape.priority = UILayoutPriorityDefaultLow;
        self.lastBtnToplandscape.priority = UILayoutPriorityDefaultLow;
        self.nextBtnToplandscape.priority = UILayoutPriorityDefaultLow;
        self.nextBtnRightlandscape.priority = UILayoutPriorityDefaultLow;
        self.searchNumToplandscape.priority = UILayoutPriorityDefaultLow;
        
        
    }
    else if(UIInterfaceOrientationIsLandscape(oritentation)){
        self.switchTopConstraintlandscape.priority = UILayoutPriorityDefaultHigh;
        self.logTextViewToplandscape.priority = UILayoutPriorityDefaultHigh;
        self.searchTextLeftlandscape.priority = UILayoutPriorityDefaultHigh;
        self.searchToplandscape.priority = UILayoutPriorityDefaultHigh;
        self.cleanBtnToplandscape.priority = UILayoutPriorityDefaultHigh;
        self.closeBtnToplandscape.priority = UILayoutPriorityDefaultHigh;
        self.lastBtnToplandscape.priority = UILayoutPriorityDefaultHigh;
        self.nextBtnToplandscape.priority = UILayoutPriorityDefaultHigh;
        self.nextBtnRightlandscape.priority = UILayoutPriorityDefaultHigh;
        self.searchNumToplandscape.priority = UILayoutPriorityDefaultHigh;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)switchClick:(UISegmentedControl *)sender {
    bool hidden = sender.selectedSegmentIndex != 0;
    self.searchNum.hidden = hidden;
    self.searchText.hidden = hidden;
    self.lastBtn.hidden = hidden;
    self.nextBtn.hidden = hidden;
    if (hidden) {
        if([self.searchText isFirstResponder]){
            [self.searchText resignFirstResponder];
        }
    }
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
#pragma mark UITextFieldDelegate implementation

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    [self.searchResult removeAllObjects];
    return YES;
}

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
            if (startLoction >= 0) {
                NSRange range = NSMakeRange(startLoction, self.searchStr.length);
                [self selectAndVisibleWordWithRange:range];
                self.searchNum.text = [NSString stringWithFormat:@"%d/%d",1,self.searchResult.count];
            }
        }
    }

    
    return YES;
}

- (void)searchTextFieldDidChangeValue:(UITextField *)textField{
    self.searchStr = textField.text;
    if (self.searchTextFieldDidChangeValue) {
        self.searchTextFieldDidChangeValue(self.searchStr);
    }
}

@end
