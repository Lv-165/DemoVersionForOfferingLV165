//
//  HMImgurManager.h
//  lv-165IOS
//
//  Created by Volodymyr Halamiy on 12/28/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMImgurManager : NSObject

+ (void)uploadPhoto:(NSData *)imageData
              title:(NSString *)title
        description:(NSString *)description
      imgurClientId:(NSString *)clientId
    completionBlock:(void(^)(NSString *result))completion
       failureBlock:(void(^)(NSURLResponse *response, NSError *error, NSInteger status))failureBlock;

@end
