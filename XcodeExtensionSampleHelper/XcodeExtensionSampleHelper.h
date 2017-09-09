//
//  XcodeExtensionSampleHelper.h
//  XcodeExtensionSampleHelper
//
//  Created by Yoshitaka Seki on 2017/09/09.
//  Copyright © 2017年 takasek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XcodeExtensionSampleHelperProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface XcodeExtensionSampleHelper : NSObject <XcodeExtensionSampleHelperProtocol>
@end
