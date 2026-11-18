#import "FaceViewController.h"
#import "FaceBundleListViewController.h"
#import "Defines.h"
#import <NanoTimeKit/NanoTimeKit.h>

@interface FaceViewController () <FaceBundleListViewControllerDelegate>
@property (nullable, nonatomic, retain, direct) NTKFaceViewController *faceViewController;
@end

@implementation FaceViewController

- (void)dealloc {
    [_faceViewController release];
    [super dealloc];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CLKDevice *device = CLKDevice.currentDevice;
    NSString * _Nullable selectedFaceIdentifier = [NSUserDefaults.standardUserDefaults stringForKey:selectedFaceIdentifierKey()];
    
    __block __kindof NTKFaceBundle * _Nullable firstBundle = nil;
    __block __kindof NTKFaceBundle * _Nullable matchedBundle = nil;
    
    [NTKFaceBundleManager.sharedManager enumerateFaceBundlesOnDevice:device includingLegacy:YES withBlock:^(__kindof NTKFaceBundle *faceBundle) {
        if (firstBundle == nil) {
            firstBundle = [faceBundle retain];
        }
        if (selectedFaceIdentifier != nil && matchedBundle == nil) {
            NSString * _Nullable identifier = [[faceBundle class] identifier];
            if ([identifier isEqualToString:selectedFaceIdentifier]) {
                matchedBundle = [faceBundle retain];
            }
        }
    }];
    
    __kindof NTKFaceBundle * _Nullable initialBundle = matchedBundle != nil ? matchedBundle : firstBundle;
    if (initialBundle != nil) {
        [self _showFaceFromBundle:initialBundle];
    }
    [matchedBundle release];
    [firstBundle release];
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_didTriggerLongPressGestureRecognizer:)];
    [self.view addGestureRecognizer:longPressGestureRecognizer];
    [longPressGestureRecognizer release];
}

- (void)_showFaceFromBundle:(__kindof NTKFaceBundle *)faceBundle __attribute__((objc_direct)) {
    if (self.faceViewController != nil) {
        [self.faceViewController willMoveToParentViewController:nil];
        [self.faceViewController.view removeFromSuperview];
        [self.faceViewController removeFromParentViewController];
        self.faceViewController = nil;
    }
    
    CLKDevice *device = CLKDevice.currentDevice;
    __kindof NTKFace * _Nullable face = [faceBundle defaultFaceForDevice:device];
    if (face == nil) {
        NSLog(@"No default face for bundle: %@", faceBundle);
        return;
    }
    
    NTKFaceViewController *faceViewController = [[NTKFaceViewController alloc] initWithFace:face configuration:nil];
    [self addChildViewController:faceViewController];
    faceViewController.view.frame = self.view.bounds;
    faceViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:faceViewController.view];
    [faceViewController didMoveToParentViewController:self];
    
    self.faceViewController = faceViewController;
    [faceViewController release];
}

- (void)_didTriggerLongPressGestureRecognizer:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;
    
    FaceBundleListViewController *listViewController = [[FaceBundleListViewController alloc] init];
    listViewController.delegate = self;
    [self presentViewController:listViewController animated:YES completion:nil];
    [listViewController release];
}

#pragma mark - FaceBundleListViewControllerDelegate

- (void)faceBundleListViewController:(FaceBundleListViewController *)viewController didSelectFaceBundle:(__kindof NTKFaceBundle *)faceBundle {
    NSString * _Nullable identifier = [[faceBundle class] identifier];
    if (identifier != nil) {
        [NSUserDefaults.standardUserDefaults setObject:identifier forKey:selectedFaceIdentifierKey()];
    }
    
    [self _showFaceFromBundle:faceBundle];
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
