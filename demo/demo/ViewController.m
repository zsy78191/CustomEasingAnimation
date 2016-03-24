//
//  ViewController.m
//  demo
//
//  Created by 张超 on 16/3/24.
//  Copyright © 2016年 gerinn. All rights reserved.
//

#import "ViewController.h"
#import "CustomEasingAnimation.h"

@interface ViewController ()
{
    BOOL _reverse;
}
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIView *b1;
@property (weak, nonatomic) IBOutlet UIView *b2;
@property (weak, nonatomic) IBOutlet UIView *b3;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)animate:(id)sender {
    
    CGFloat interval = 0.4;
    
    if (_reverse) {
        [CustomEasingAnimation easingFrom:200 to:0 interval:interval timing:[CAMediaTimingFunction functionWithControlPoints:0.5 :0.000 :0.5 :1] block:^(CGFloat value) {
            
            self.b1.transform = CGAffineTransformMakeTranslation(value, 0);
            self.label.text = [NSString stringWithFormat:@"%.2f",value];
            
        } comeplte:^{
            
        }];
        //0.420, 0.000, 0.480, 1
        [CustomEasingAnimation easingFrom:200 to:0 interval:interval timing:[CAMediaTimingFunction functionWithControlPoints:0.5 :0.000 :0.5 :1.5] block:^(CGFloat value) {
            
            self.b2.transform = CGAffineTransformMakeTranslation(value, 0);
            
            
        } comeplte:^{
            
        }];
        
        [CustomEasingAnimation easingFrom:1 to:0 interval:interval timing:[CAMediaTimingFunction functionWithControlPoints:0.2 :0.2 :0.8 :0.8] block:^(CGFloat value) {
            
            
            self.b3.transform = CGAffineTransformMakeTranslation(value*200, 0);
            self.b3.alpha = 1 - value;
            
        } comeplte:^{
            
        }];
    }
    else
    {
        [CustomEasingAnimation easingFrom:0 to:200 interval:interval timing:[CAMediaTimingFunction functionWithControlPoints:0.5 :0.000 :0.5 :1] block:^(CGFloat value) {
            
            
            self.b1.transform = CGAffineTransformMakeTranslation(value, 0);
            self.label.text = [NSString stringWithFormat:@"%.2f",value];
            
        } comeplte:^{
            
        }];
        
        [CustomEasingAnimation easingFrom:0 to:200 interval:interval timing:[CAMediaTimingFunction functionWithControlPoints:0.5 :0.000 :0.5 :1.5] block:^(CGFloat value) {
            
            
            self.b2.transform = CGAffineTransformMakeTranslation(value, 0);
 
        } comeplte:^{
            
        }];
        
        [CustomEasingAnimation easingFrom:0 to:1 interval:interval timing:[CAMediaTimingFunction functionWithControlPoints:0.2 :0.2 :0.8 :0.8] block:^(CGFloat value) {
            
            self.b3.transform = CGAffineTransformMakeTranslation(value*200, 0);
            self.b3.alpha = 1 - value;
            
            
        } comeplte:^{
            
        }];
    }
    
    _reverse = !_reverse;
}

@end
