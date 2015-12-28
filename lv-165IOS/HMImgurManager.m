//
//  HMImgurManager.m
//  lv-165IOS
//
//  Created by Volodymyr Halamiy on 12/28/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import "HMImgurManager.h"

@implementation HMImgurManager

+ (void)uploadPhoto:(NSData *)imageData
              title:(NSString *)title
        description:(NSString *)description
      imgurClientId:(NSString *)clientId
    completionBlock:(void(^)(NSString *result))completion
       failureBlock:(void(^)(NSURLResponse *response, NSError *error, NSInteger status))failureBlock {
    
    NSAssert(imageData, @"Image data is required");
    NSAssert(clientId, @"Client ID is required");
    
    NSString *urlString = @"https://api.imgur.com/3/upload.json";
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSMutableData *requestBody = [NSMutableData new];
    
    NSString *boundary = @"---------------------------0983745982375409872438752038475287";
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    [request addValue:[NSString stringWithFormat:@"Client-ID %@", clientId] forHTTPHeaderField:@"Authorization"];
    
    // Image File Data
    [requestBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [requestBody appendData:[@"Content-Disposition: attachment; name=\"image\"; filename=\".png\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [requestBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [requestBody appendData:[NSData dataWithData:imageData]];
    [requestBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Title parameter
    if (title) {
        [requestBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]
                                 dataUsingEncoding:NSUTF8StringEncoding]];
        [requestBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"title\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [requestBody appendData:[title dataUsingEncoding:NSUTF8StringEncoding]];
        [requestBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // Description parameter
    if (description) {
        [requestBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]
                                 dataUsingEncoding:NSUTF8StringEncoding]];
        [requestBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"description\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [requestBody appendData:[description dataUsingEncoding:NSUTF8StringEncoding]];
        [requestBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [requestBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:requestBody];
    
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([responseDictionary valueForKeyPath:@"data.error"]) {
            if (failureBlock) {
                if (!error) {
                    // If no error has been provided, create one based on the response received from the server
                    error = [NSError errorWithDomain:@"imgurmanager"
                                                code:10000
                                            userInfo:@{NSLocalizedFailureReasonErrorKey : [responseDictionary valueForKeyPath:@"data.error"]}];
                }
                failureBlock(response, error, [[responseDictionary valueForKey:@"status"] intValue]);
            }
        } else {
            if (completion) {
                completion([responseDictionary valueForKeyPath:@"data.link"]);
            }
            
        }
        
    }];
}

@end
