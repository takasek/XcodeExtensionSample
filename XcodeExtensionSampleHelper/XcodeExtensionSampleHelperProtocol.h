//
//  XcodeExtensionSampleHelperProtocol.h
//  XcodeExtensionSampleHelper
//
//  Created by Yoshitaka Seki on 2017/09/09.
//  Copyright © 2017年 takasek. All rights reserved.
//

@import Foundation;

typedef void (^HelperResultHandler)(NSInteger status, NSString * _Nonnull, NSString * _Nonnull);

@protocol XcodeExtensionSampleHelperProtocol

- (void)executeInDirectory:(NSString * _Nonnull)directory
             withArguments:(NSArray<NSString *> * _Nonnull)arguments
                     reply:(HelperResultHandler _Nonnull)reply
NS_SWIFT_NAME(execute(in:with:reply:));

@end


