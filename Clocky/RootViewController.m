//
//  RootViewController.m
//  Clocky
//
//  Created by Jinwoo Kim on 11/18/26.
//

#import "RootViewController.h"
#import <NanoTimeKit/NanoTimeKit.h>

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NTKFaceViewController * _Nullable faceViewController = [self makeFirstFaceViewController];
    if (faceViewController == nil) {
        NSLog(@"No face found.");
        return;
    }
    
    [self addChildViewController:faceViewController];
    faceViewController.view.frame = self.view.bounds;
    faceViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:faceViewController.view];
    [faceViewController didMoveToParentViewController:self];
}

- (NTKFaceViewController * _Nullable)makeFirstFaceViewController __attribute__((objc_direct)) {
    CLKDevice *device = CLKDevice.currentDevice;
    __block NTKFace * _Nullable firstFace = nil;
    
    [NTKFaceBundleManager.sharedManager enumerateFaceBundlesOnDevice:device withBlock:^(NTKFaceBundle *faceBundle) {
        if (firstFace != nil) return;
        firstFace = [[faceBundle defaultFaceForDevice:device] retain];
    }];
    
    if (firstFace == nil) return nil;
    
    NTKFaceViewController *faceViewController = [[NTKFaceViewController alloc] initWithFace:firstFace configuration:nil];
    [firstFace release];
    return [faceViewController autorelease];
}

@end
