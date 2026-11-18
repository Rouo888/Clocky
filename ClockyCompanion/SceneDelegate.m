#import "SceneDelegate.h"
#import "RootViewController.h"

@implementation SceneDelegate

- (void)dealloc {
    [_window release];
    [super dealloc];
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) return;

    UIWindow *window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    RootViewController *rootViewController = [[RootViewController alloc] init];
    window.rootViewController = rootViewController;
    [rootViewController release];
    self.window = window;
    [window makeKeyAndVisible];
    [window release];
}

@end
