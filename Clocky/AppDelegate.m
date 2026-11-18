//
//  AppDelegate.m
//  Clocky
//
//  Created by Jinwoo Kim on 11/18/26.
//

#import "AppDelegate.h"
#import "SceneDelegate.h"
#import <NanoTimeKit/NanoTimeKit.h>
#import <objc/runtime.h>

static BOOL swizzled_NTKFaceDescriptor_isAvailableForDevice(NTKFaceDescriptor *self, SEL _cmd, CLKDevice *device) {
    return YES;
}

static BOOL swizzled_NTKFace_isRestrictedForDevice(Class self, SEL _cmd, CLKDevice *device) {
    return NO;
}

@interface AppDelegate ()
@property (nonatomic) BOOL hasReceivedNonClockKitEvent;
@end

@implementation AppDelegate

+ (void)load {
    Method isAvailableMethod = class_getInstanceMethod([NTKFaceDescriptor class], @selector(isAvailableForDevice:));
    assert(isAvailableMethod != NULL);
    method_setImplementation(isAvailableMethod, (IMP)swizzled_NTKFaceDescriptor_isAvailableForDevice);
    
    [NTKFaceBundleManager.sharedManager.loader enumerateFaceBundleClassesIgnoringCache:NO withBlock:^(__kindof NTKFaceBundle *faceBundle) {
        Class faceClass = faceBundle.faceClass;
        Method isRestrictedMethod = class_getClassMethod(faceClass, @selector(isRestrictedForDevice:));
        if (isRestrictedMethod != NULL) {
            method_setImplementation(isRestrictedMethod, (IMP)swizzled_NTKFace_isRestrictedForDevice);
        }
    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions {
    NSURL *scCacheURL = [[NSFileManager.defaultManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:@"Saved Application State" isDirectory:YES];
    [NSFileManager.defaultManager removeItemAtURL:scCacheURL error:NULL];
    
    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    UISceneConfiguration *configuration = [connectingSceneSession.configuration copy];
    configuration.delegateClass = [SceneDelegate class];
    return [configuration autorelease];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // noop
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // noop
}

- (void)didReceiveNonClockKitEvent {
    // noop
}

- (id _Nullable)extendLaunchTest {
    return nil;
}

@end
