//
//  InstgrmLoginVC.m
//  my insta
//
//  Created by Alexis Schreier on 01/06/17.
//  Copyright © 2017 MoonSandApps. All rights reserved.
//

#import "DataSource.h"
#import "InstgrmLoginVC.h"

@interface InstgrmLoginVC () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation InstgrmLoginVC
#pragma mark
#pragma mark - Properties
#pragma mark
NSString *const InstgrmLoginVCDidGetAccessTokenNotification = @"InstgrmLoginVCDidGetAccessTokenNotification";
#pragma mark
#pragma mark - UIViewController Methods
#pragma mark
- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate = self;
    NSString *urlString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token", [DataSource instgrmClientID], [self redirectURI]];
    NSURL *url = [NSURL URLWithString: urlString];
    if (url) {
        NSURLRequest *request = [NSURLRequest requestWithURL: url];
        [self.webView loadRequest: request];
    }
}
#pragma mark
#pragma mark - UIWebViewDelegate Methods
#pragma mark
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = request.URL.absoluteString;
    if ([urlString hasPrefix: [self redirectURI]]) {
        NSRange rangeOfAccessTokenParameter = [urlString rangeOfString: @"access_token="];
        NSUInteger indexOfTokenStarting = rangeOfAccessTokenParameter.location + rangeOfAccessTokenParameter.length;
        NSString *accessToken = [urlString substringFromIndex:indexOfTokenStarting];
        [[NSNotificationCenter defaultCenter] postNotificationName: InstgrmLoginVCDidGetAccessTokenNotification object:accessToken];
        return NO;
    }
    return YES;
}
#pragma mark
#pragma mark - Instgrm Client
#pragma mark
- (NSString *)redirectURI {
    return @"https://github.com/";
}

- (void)clearInstgrmCookies {
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        NSRange domainRange = [cookie.domain rangeOfString:@"instagram.com"];
        if(domainRange.location != NSNotFound) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}
#pragma mark
#pragma mark - Dealloc
#pragma mark
- (void)dealloc {
    self.webView.delegate = nil;
    [self clearInstgrmCookies];
}
@end








