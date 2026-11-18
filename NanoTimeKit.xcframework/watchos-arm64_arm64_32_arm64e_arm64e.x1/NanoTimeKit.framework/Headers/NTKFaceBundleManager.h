#import <Foundation/Foundation.h>
#import <NanoTimeKit/CLKDevice.h>
#import <NanoTimeKit/NTKFaceBundle.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NTKFaceBundleManager : NSObject
@property (class, nonatomic, readonly, strong) NTKFaceBundleManager *sharedManager;
- (void)enumerateFaceBundlesOnDevice:(CLKDevice *)device withBlock:(void (NS_NOESCAPE ^)(__kindof NTKFaceBundle *faceBundle))block;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
