//
//  SceneDelegate.m
//  Clocky
//
//  Created by Jinwoo Kim on 11/18/26.
//

#import "SceneDelegate.h"
#import "RootViewController.h"

@implementation SceneDelegate

- (void)dealloc {
    [_window release];
    [super dealloc];
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    
    RootViewController *rootViewController = [[RootViewController alloc] init];
    window.rootViewController = rootViewController;
    [rootViewController release];
    
    self.window = window;
    [window makeKeyAndVisible];
    [window release];
}

@end
