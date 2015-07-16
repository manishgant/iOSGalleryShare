//
//  TweetDisplayView.m
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/15/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TweetDisplayView.h"

@interface TwitterDisplayView()

@end

@implementation TwitterDisplayView

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    NSURLRequest* request = [NSURLRequest requestWithURL:self->_imageURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    [self->_displayTweetWebView loadRequest:request];
    
}



@end