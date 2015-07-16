//
//  TwitterVideoUploader.m
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/16/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwitterVideoUploader.h"

@interface TwitterVideoUploader()

@end

@implementation TwitterVideoUploader

+(BOOL)userHasAccessToFacebook
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook];
}

+(BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}



+(void)uploadTwitterVideo:(NSData*)videoData account:(ACAccount*)account withCompletion:(dispatch_block_t)completion{
    
    NSURL *twitterPostURL = [[NSURL alloc] initWithString:@"https://upload.twitter.com/1.1/media/upload.json"];
    
    NSDictionary *postParams = @{@"command": @"INIT",
                                 @"total_bytes" : [NSNumber numberWithInteger: videoData.length].stringValue,
                                 @"media_type" : @"video/mp4"
                                 };
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:twitterPostURL parameters:postParams];
    request.account = account;
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSLog(@"HTTP Response: %li, responseData: %@", (long)[urlResponse statusCode], [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        if (error) {
            NSLog(@"There was an error:%@", [error localizedDescription]);
        } else {
            NSMutableDictionary *returnedData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
            
            NSString *mediaID = [NSString stringWithFormat:@"%@", [returnedData valueForKey:@"media_id_string"]];
            
            [TwitterVideoUploader tweetVideoStage2:videoData mediaID:mediaID account:account withCompletion:completion];
            
            NSLog(@"Stage1 success, mediaID -> %@", mediaID);
        }
    }];
}

+(void)tweetVideoStage2:(NSData*)videoData mediaID:(NSString *)mediaID account:(ACAccount*)account withCompletion:(dispatch_block_t)completion{
    
    NSURL *twitterPostURL = [[NSURL alloc] initWithString:@"https://upload.twitter.com/1.1/media/upload.json"];
    NSDictionary *postParams = @{@"command": @"APPEND",
                                 @"media_id" : mediaID,
                                 @"segment_index" : @"0",
                                 };
    
    SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:twitterPostURL parameters:postParams];
    postRequest.account = account;
    
    [postRequest addMultipartData:videoData withName:@"media" type:@"video/mp4" filename:@"video"];
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSLog(@"Stage2 HTTP Response: %li, %@", (long)[urlResponse statusCode], [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        if (!error) {
            [TwitterVideoUploader tweetVideoStage3:videoData mediaID:mediaID account:account withCompletion:completion];
        }
        else {
            NSLog(@"Error stage 2 - %@", error);
        }
    }];
}

+(void)tweetVideoStage3:(NSData*)videoData mediaID:(NSString *)mediaID account:(ACAccount*)account withCompletion:(dispatch_block_t)completion{
    
    NSURL *twitterPostURL = [[NSURL alloc] initWithString:@"https://upload.twitter.com/1.1/media/upload.json"];
    
    NSDictionary *postParams = @{@"command": @"FINALIZE",
                                 @"media_id" : mediaID };
    
    SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:twitterPostURL parameters:postParams];
    
    // Set the account and begin the request.
    postRequest.account = account;
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSLog(@"Stage3 HTTP Response: %li, %@", (long)[urlResponse statusCode], [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        if (error) {
            NSLog(@"Error stage 3 - %@", error);
        } else {
            [TwitterVideoUploader tweetVideoStage4:videoData mediaID:mediaID account:account withCompletion:completion];
        }
    }];
}

+(void)tweetVideoStage4:(NSData*)videoData mediaID:(NSString *)mediaID account:(ACAccount*)account withCompletion:(dispatch_block_t)completion{
   
    NSDate *date = [[NSDate alloc]init];
    
    //Declare Date Formatter to format date according to problem
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    NSString *OSVersion = (NSString *)[[UIDevice currentDevice] systemVersion];
    
    NSString *DeviceInfo = (NSString *)[[UIDevice currentDevice] model];
    
    NSString *andrewID = @"manantha";
    
    
    
    NSURL *twitterPostURL = [[NSURL alloc] initWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
    NSString *statusContent = [NSString stringWithFormat:@"@MobileApp4 %@ %@ %@ %@",andrewID,dateString,DeviceInfo,OSVersion];
    
    // Set the parameters for the third twitter video request.
    NSDictionary *postParams = @{@"status": statusContent,
                                 @"media_id" : mediaID};
    
    SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:twitterPostURL parameters:postParams];
    postRequest.account = account;
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSLog(@"Stage4 HTTP Response: %li, %@", (long)[urlResponse statusCode], [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        if (error) {
            NSLog(@"Error stage 4 - %@", error);
        } else {
            if ([urlResponse statusCode] == 200){
                NSLog(@"upload success !");
                DispatchMainThread(^(){completion();});
            }
        }
    }];
    
}

@end