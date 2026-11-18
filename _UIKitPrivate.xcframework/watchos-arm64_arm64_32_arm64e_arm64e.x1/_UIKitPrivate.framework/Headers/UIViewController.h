#import <_UIKitPrivate/UIResponder.h>
#import <_UIKitPrivate/UIView.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UIKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UIViewController : UIResponder
@property (null_resettable, nonatomic, strong) UIView *view;
- (void)viewDidLoad;
@end

@interface UIViewController (UIContainerViewControllerProtectedMethods)
- (void)addChildViewController:(UIViewController *)childController;
@end

@interface UIViewController (UIContainerViewControllerCallbacks)
- (void)didMoveToParentViewController:(nullable UIViewController *)parent;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
