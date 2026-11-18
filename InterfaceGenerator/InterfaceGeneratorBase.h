#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface InterfaceGeneratorBase : NSObject
@property (class, nonatomic, readonly) NSString *frameworkName;
+ (BOOL)generateToURL:(NSURL *)url __attribute__((objc_direct));
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
