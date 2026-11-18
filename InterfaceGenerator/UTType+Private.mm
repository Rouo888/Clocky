#import "UTType+Private.h"
#include <objc/runtime.h>

typedef struct __attribute__((aligned(16))) {
    Class isa;
    id _Nullable recordType; // _UTDeclaredTypeRecord *
    NSString *identifier;
} Tag;

Tag xcFrameworkTag = {
    objc_lookUpClass("_UTCoreType"),
    NULL,
    @"dyn.ah62d4rv4ge81u25gsmu043p1r73g0"
};
UTType * const UTTypeXCFramework = (UTType *)&xcFrameworkTag;

Tag tbdTag = {
    objc_lookUpClass("_UTCoreType"),
    NULL,
    @"com.apple.text-based-dylib"
};
UTType * const UTTypeTBD = (UTType *)&tbdTag;
