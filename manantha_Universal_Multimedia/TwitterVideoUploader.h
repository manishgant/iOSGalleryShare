//
//  TwitterVideoUploader.h
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/16/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#define DispatchMainThread(block, ...) if(block) dispatch_async(dispatch_get_main_queue(), ^{ block(__VA_ARGS__); })

@interface TwitterVideoUploader : NSObject

+(void)uploadTwitterVideo:(NSData*)videoData account:(ACAccount*)account withCompletion:(dispatch_block_t)completion;

+(BOOL)userHasAccessToTwitter;

@end
