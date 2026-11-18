#import "InterfaceGeneratorBase.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import "UTType+Private.h"

@interface InterfaceGeneratorBase ()
@property (class, nonatomic, readonly, direct) NSString *baseLibraryIdentifier;
@property (class, nonatomic, readonly, direct) NSArray<NSString *> *baseTargets;
@end

@implementation InterfaceGeneratorBase

+ (NSString *)frameworkName {
    abort();
}

+ (NSString *)baseLibraryIdentifier {
    return @"watchos-arm64_x86_64-simulator";
}

+ (NSArray<NSString *> *)baseTargets {
    return @[@"i386-watchos-simulator", @"x86_64-watchos-simulator", @"arm64-watchos-simulator"];
}

+ (BOOL)_checkDirectoryExists:(NSURL *)url __attribute__((objc_direct)) {
    NSFileManager *fileManager = NSFileManager.defaultManager;
    BOOL isDirectory;
    BOOL exists = [fileManager fileExistsAtPath:url.path isDirectory:&isDirectory];
    
    if (!isDirectory || !exists) {
        NSLog(@"Not found: %@", url);
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)_checkFileExists:(NSURL *)url __attribute__((objc_direct)) {
    NSFileManager *fileManager = NSFileManager.defaultManager;
    BOOL isDirectory;
    BOOL exists = [fileManager fileExistsAtPath:url.path isDirectory:&isDirectory];
    
    if (isDirectory || !exists) {
        NSLog(@"Not found: %@", url);
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)_writeTBDFromURL:(NSURL *)fromURL toURL:(NSURL *)toURL newTargets:(NSArray<NSString *> *)newTargets {
    if ([toURL isEqual:fromURL]) {
        return YES;
    }
    
    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSError * _Nullable error = nil;
    
    if ([fileManager fileExistsAtPath:toURL.path]) {
        BOOL success = [fileManager removeItemAtURL:toURL error:&error];
        if (!success) {
            NSLog(@"%@", error);
            return NO;
        }
    }
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:fromURL options:0 error:&error];
    if (data == nil) {
        NSLog(@"%@", error);
        return NO;
    }
    
    NSMutableString *string = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [data release];
    [string replaceOccurrencesOfString:[self.baseTargets componentsJoinedByString:@", "] withString:[newTargets componentsJoinedByString:@", "] options:0 range:NSMakeRange(0, string.length)];
    BOOL success = [string writeToURL:toURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
    [string release];
    
    if (!success) {
        NSLog(@"%@", error);
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)_copyHeadersToURL:(NSURL *)toURL fromURL:(NSURL *)fromURL __attribute__((objc_direct)) {
    if ([toURL isEqual:fromURL]) {
        return YES;
    }
    
    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSError * _Nullable error = nil;
    BOOL isDirectory;
    BOOL exists = [fileManager fileExistsAtPath:fromURL.path isDirectory:&isDirectory];
    
    if (!exists) {
        exists = [fileManager fileExistsAtPath:toURL.path];
        if (exists) {
            BOOL success = [fileManager removeItemAtURL:toURL error:&error];
            if (!success) {
                NSLog(@"%@", error);
                return NO;
            }
        }
        
        return YES;
    }
    
    if (!isDirectory) {
        NSLog(@"%@ is not a directory.", fromURL);
        return NO;
    }
    
    exists = [fileManager fileExistsAtPath:toURL.path];
    if (exists) {
        BOOL success = [fileManager removeItemAtURL:toURL error:&error];
        if (!success) {
            NSLog(@"%@", error);
            return NO;
        }
    }
    
    BOOL success = [fileManager copyItemAtURL:fromURL toURL:toURL error:&error];
    if (!success) {
        NSLog(@"%@", error);
        return NO;
    }
    
    return YES;
}

+ (BOOL)generateToURL:(NSURL *)url {
    NSDictionary<NSString *, NSArray<NSString *> *> *libraryToTargets = @{
        @"watchos-arm64_arm64_32_arm64e_arm64e.x1": @[@"armv7k-watchos", @"arm64-watchos", @"arm64e-watchos", @"arm64e.x1-watchos", @"arm64_32-watchos"],
        @"watchos-arm64_x86_64-simulator": @[@"i386-watchos-simulator", @"x86_64-watchos-simulator", @"arm64-watchos-simulator"]
    };
    
    NSURL *frameworkURL = url;
    frameworkURL = [frameworkURL URLByAppendingPathComponent:self.frameworkName conformingToType:UTTypeXCFramework];
    if (![InterfaceGeneratorBase _checkDirectoryExists:frameworkURL]) {
        return NO;
    }
    
    NSURL *baseFrameworkURL = [frameworkURL URLByAppendingPathComponent:self.baseLibraryIdentifier isDirectory:YES];
    baseFrameworkURL = [baseFrameworkURL URLByAppendingPathComponent:self.frameworkName conformingToType:UTTypeFramework];
    if (![InterfaceGeneratorBase _checkDirectoryExists:baseFrameworkURL]) {
        return NO;
    }
    
    NSURL *baseHeadersURL = [baseFrameworkURL URLByAppendingPathComponent:@"Headers" isDirectory:YES];
    
    NSURL *baseTBDURL = [baseFrameworkURL URLByAppendingPathComponent:self.frameworkName conformingToType:UTTypeTBD];
    if (![InterfaceGeneratorBase _checkFileExists:baseTBDURL]) {
        return NO;
    }
    
    for (NSString *libraryName in libraryToTargets.allKeys) {
        NSURL *targetFrameworkURL = frameworkURL;
        targetFrameworkURL = [targetFrameworkURL URLByAppendingPathComponent:libraryName isDirectory:YES];
        targetFrameworkURL = [targetFrameworkURL URLByAppendingPathComponent:self.frameworkName conformingToType:UTTypeFramework];
        
        if (![InterfaceGeneratorBase _checkDirectoryExists:targetFrameworkURL]) {
            return NO;
        }
        
        NSURL *targetHeadersURL = [targetFrameworkURL URLByAppendingPathComponent:@"Headers" isDirectory:YES];
        
        BOOL result = [InterfaceGeneratorBase _copyHeadersToURL:targetHeadersURL fromURL:baseHeadersURL];
        if (!result) {
            return NO;
        }
        
        NSURL *targetTBDURL = [targetFrameworkURL URLByAppendingPathComponent:self.frameworkName conformingToType:UTTypeTBD];
        if (![InterfaceGeneratorBase _checkFileExists:targetTBDURL]) {
            return NO;
        }
        result = [InterfaceGeneratorBase _writeTBDFromURL:baseTBDURL toURL:targetTBDURL newTargets:libraryToTargets[libraryName]];
        if (!result) {
            return NO;
        }
    }
    
    return YES;
}

@end
