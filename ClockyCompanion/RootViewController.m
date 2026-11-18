#import "RootViewController.h"

@implementation RootViewController

- (void)loadView {
    UILabel *label = [[UILabel alloc] init];
    label.text = @"Open the Watch app to install Clocky.";
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.backgroundColor = UIColor.systemBackgroundColor;
    self.view = label;
    [label release];
}

@end
