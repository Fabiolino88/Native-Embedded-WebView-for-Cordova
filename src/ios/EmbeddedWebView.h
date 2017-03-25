//
// EmbeddedWebView for cordova
// Created by Fabio Santoro
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>

@interface EmbeddedWebView : CDVPlugin <UIWebViewDelegate>

- (void)showEmbeddedWebView:(CDVInvokedUrlCommand *)command;
- (void)closeEmbeddedWebView:(CDVInvokedUrlCommand *)command;
- (void)webviewHistoryBack:(CDVInvokedUrlCommand *)command;
- (void)webviewHistoryForward:(CDVInvokedUrlCommand *)command;

@end
