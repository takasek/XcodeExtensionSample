//
//  XcodeExtensionSampleHelperProtocol.h
//  XcodeExtensionSampleHelper
//
//  Created by Yoshitaka Seki on 2017/09/09.
//  Copyright © 2017年 takasek. All rights reserved.
//

@import Foundation;

typedef void (^HelperResultHandler)(NSInteger status);

@protocol XcodeExtensionSampleHelperProtocol

- (void)writeText:(NSString * _Nonnull)text
               to:(NSString * _Nonnull)directory
            reply:(HelperResultHandler _Nonnull)reply
NS_SWIFT_NAME(write(text:to:reply:));

@end


