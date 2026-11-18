#import "AppDelegate.h"
#import "SceneDelegate.h"

@implementation AppDelegate

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    UISceneConfiguration *configuration = [connectingSceneSession.configuration copy];
    configuration.delegateClass = [SceneDelegate class];
    return [configuration autorelease];
}

@end
