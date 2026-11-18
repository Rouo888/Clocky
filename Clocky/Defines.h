//
//  Defines.h
//  Clocky
//
//  Created by Jinwoo Kim on 11/18/26.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#define CKT_EXTERN  extern "C" __attribute__((visibility ("default")))
#else
#define CKT_EXTERN  extern __attribute__((visibility ("default")))
#endif

NS_ASSUME_NONNULL_BEGIN

CKT_EXTERN NSString * selectedFaceIdentifierKey(void);

NS_ASSUME_NONNULL_END
