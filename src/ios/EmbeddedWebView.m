//
// EmbeddedWebView for cordova
// Created by Fabio Santoro
//

#import "EmbeddedWebView.h"

@interface EmbeddedWebView () {
    NSString *urlString;
    CGFloat webviewWidth;
    CGFloat webviewHeight;
    CGFloat webviewPositionX;
    CGFloat webviewPositionY;
    BOOL showIosToolBar;
    BOOL showSpinnerWhileLoading;
    NSString *toolBarStyle;
}

@property (strong, nonatomic) UIWebView *nativeWebView;
@property (strong, nonatomic) UIViewController *cordovaController;

//UI for the optional forward and back button bar
@property (strong, nonatomic) UIToolbar *toolBar;

//UI for the optional loading spinner view
@property (strong, nonatomic) UIView *spinnerView;
@property (strong, nonatomic) UIActivityIndicatorView *loadingSpinner;

@end

/**
 * Parameter from the call to the plugin:
 * 1) webview_width
 * 2) webview_height
 * 3) webview_position_x
 * 4) webview_position_y
 * 5) showIosToolBar (boolean for back and forward toolbar - just for ios platform)
 * 6) showSpinnerWhileLoading (boolean to show a spinner while the webview is loading)
 * 7) url
 * 8) toolBarStyle -> ("dark" or "light")
 * */

@implementation EmbeddedWebView

@synthesize nativeWebView, cordovaController, toolBar, spinnerView, loadingSpinner;

//Constants declaration
CGFloat TOOL_BAR_HEIGHT = 44; //The height of the toolbar is set as 44 by default
//End constants

#pragma mark ShowEmebeddedWebiew Methods
- (void)showEmbeddedWebView:(CDVInvokedUrlCommand *)command {
    
    //Check if the webview is already open. if it is return an error
    if (nativeWebView != nil) {
        [self sendErrorCallBack:command withMessage:@"Another instance of the Native webview is already in the view, close it before to create a new one"];
        return;
    }

    //If is everything ok procede with the params check
    BOOL areParamsValid = [self initializePluginParameters:command.arguments[0] withCommand:command];
    if (areParamsValid) {
        [self loadWebviewComponents:webviewWidth widthHeight:webviewHeight widthPositionX:webviewPositionX withPositionY:webviewPositionY withCommand:command];
    } else {
        [self sendErrorCallBack:command withMessage:@"No valid parameters has been sent with the plugin request"];
    }

}

- (BOOL)initializePluginParameters:(NSDictionary *)optObj withCommand:(CDVInvokedUrlCommand *)command {

    @try {

        urlString = optObj[@"url"];
        if (urlString == nil || urlString.length == 0) {
            [NSException raise:@"Invalid url for webview url" format:@"Invalid url has been sent with the plugin call"];
        }

        if (optObj[@"webview_width"] && [optObj[@"webview_width"] floatValue] > 0) {
            webviewWidth = [optObj[@"webview_width"] floatValue];
        } else {
            [NSException raise:@"Invalid with for webview size" format:@"Invalid width has been sent with the plugin call"];
        }


        if (optObj[@"webview_height"] && [optObj[@"webview_height"] floatValue] > 0) {
            webviewHeight = [optObj[@"webview_height"] floatValue];
        } else {
            [NSException raise:@"Invalid height for webview size" format:@"Invalid height has been sent with the plugin call"];
        }


        if (optObj[@"webview_position_x"] && [optObj[@"webview_position_x"] floatValue] >= 0) {
            webviewPositionX = [optObj[@"webview_position_x"] floatValue];
        } else {
            [NSException raise:@"Invalid position x for webview" format:@"Invalid position x has been sent with the plugin call"];
        }

        if (optObj[@"webview_position_y"] && [optObj[@"webview_position_y"] floatValue] >= 0) {
            webviewPositionY = [optObj[@"webview_position_y"] floatValue];
        } else {
            [NSException raise:@"Invalid position y for webview" format:@"Invalid position y has been sent with the plugin call"];
        }

        showIosToolBar = [optObj[@"showIosToolBar"] boolValue];
        showSpinnerWhileLoading = [optObj[@"showSpinnerWhileLoading"] boolValue];
        
        toolBarStyle = optObj[@"toolBarStyle"];
        if (toolBarStyle == nil || toolBarStyle.length == 0) {
            toolBarStyle = @"dark";
        }

        return true;

    } @catch (NSException *e) {
        [self sendErrorCallBack:command withMessage:e.reason];
        return false;
    }

}

- (void)loadWebviewComponents:(CGFloat)width widthHeight:(CGFloat)height widthPositionX:(CGFloat)positionX withPositionY:(CGFloat)positionY withCommand:(CDVInvokedUrlCommand *)command {

    //Set the main controller
    cordovaController = [[UIApplication sharedApplication] keyWindow].rootViewController;

    nativeWebView = [[UIWebView alloc] init];

    //Give the webview sizes based to the toolbar if enabled and initalize the toolbar
    if (showIosToolBar) {
        nativeWebView.frame = CGRectMake(positionX, positionY, width, height - TOOL_BAR_HEIGHT);
        
        //The position y in the view is calculated adding the webview positionY + the height of the webview itself
        [self loadToolbarOnView:positionX positionY:positionY + (height - TOOL_BAR_HEIGHT) width:width height:TOOL_BAR_HEIGHT];
    } else {
        nativeWebView.frame = CGRectMake(positionX, positionY, width, height);
    }

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];

    [nativeWebView loadRequest:urlRequest];
    [nativeWebView setScalesPageToFit:YES];
    [nativeWebView setDelegate:self];
    [cordovaController.view addSubview:nativeWebView];
    [cordovaController.view bringSubviewToFront:nativeWebView];
    
    //Start spinner view if true
    if (showSpinnerWhileLoading)
        [self showLoadingView:nativeWebView];
    
    
    //At the end send the success loaded event
    [self sendSuccessCallBack:command];

}

- (void)loadToolbarOnView:(CGFloat)originX positionY:(CGFloat)originY width:(CGFloat)width height:(CGFloat)height {
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(originX, originY, width, height)];
    
    //Adding the buttons
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"<" style:UIBarButtonItemStylePlain target:self action:@selector(historyBack)];
    
    UIBarButtonItem *barSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    barSeparator.width = 30.0;
    
    UIBarButtonItem *forwardButton = [[UIBarButtonItem alloc] initWithTitle:@">" style:UIBarButtonItemStylePlain target:self action:@selector(historyForward)];
    //End adding the buttons
    
    //Set bar style
    if ([toolBarStyle isEqualToString:@"dark"]) {
        [toolBar setBarStyle:UIBarStyleBlack];
        [backButton setTintColor:[UIColor whiteColor]];
        [forwardButton setTintColor:[UIColor whiteColor]];
    } else {
        [toolBar setBarStyle:UIBarStyleDefault];
    }
    //End bar style
    
    NSArray *commandsArray = [NSArray arrayWithObjects:backButton, barSeparator, forwardButton, nil];
    [toolBar setItems:commandsArray];
    [cordovaController.view addSubview:toolBar];
    [cordovaController.view bringSubviewToFront:toolBar];
    
}

- (void)historyBack {
    if (nativeWebView != nil) {
        [nativeWebView goBack];
    }
}

- (void)historyForward {
    if (nativeWebView != nil) {
        [nativeWebView goForward];
    }
}

- (void)showLoadingView:(UIWebView *)webview {
    
    if (spinnerView == nil) {
        spinnerView = [[UIView alloc] initWithFrame:webview.frame];
        [spinnerView setAlpha:0.5f];
        [spinnerView setBackgroundColor:[UIColor blackColor]];
        
        CGFloat loadingSpinnerPosX = (spinnerView.frame.size.width / 2) - 50;
        CGFloat loadingSpinnerPosY = (spinnerView.frame.size.height / 2) - 50;
        loadingSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(loadingSpinnerPosX, loadingSpinnerPosY, 100, 100)];
        [loadingSpinner setColor:[UIColor whiteColor]];
        
        [cordovaController.view addSubview:spinnerView];
        [cordovaController.view bringSubviewToFront:spinnerView];
        [spinnerView addSubview:loadingSpinner];
        [spinnerView bringSubviewToFront:loadingSpinner];
        
        [loadingSpinner startAnimating];
        
        //Adding 15 seconds timeout just in case the website will stack
        [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(removeLoadingView) userInfo:nil repeats:NO];
    }
    
}

- (void)removeLoadingView {
    
    if (spinnerView != nil) {
        [loadingSpinner stopAnimating];
        [loadingSpinner removeFromSuperview];
        loadingSpinner = nil;
        
        [spinnerView removeFromSuperview];
        spinnerView = nil;
    }
    
}

- (void)resetPluginVariables {
    
    if (nativeWebView != nil)
        [nativeWebView removeFromSuperview];
    
    if (spinnerView != nil)
        [spinnerView removeFromSuperview];
    
    if (toolBar != nil)
        [toolBar removeFromSuperview];
    
    webviewWidth = 0;
    webviewHeight = 0;
    webviewPositionX = 0;
    webviewPositionY = 0;
    showIosToolBar = false;
    showSpinnerWhileLoading = false;

    nativeWebView = nil;
    cordovaController = nil;
    toolBar = nil;
    spinnerView = nil;
    loadingSpinner = nil;
}

#pragma mark HandleWebview delegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    if (webView.isLoading)
        return;
    
    if (showSpinnerWhileLoading)
        [self removeLoadingView];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (!showSpinnerWhileLoading) {return true;}
    
    switch (navigationType) {
        case UIWebViewNavigationTypeLinkClicked:
            [self showLoadingView:nativeWebView];
            break;
        
        case UIWebViewNavigationTypeBackForward:
            [self showLoadingView:nativeWebView];
            break;
            
        case UIWebViewNavigationTypeFormSubmitted:
            [self showLoadingView:nativeWebView];
            break;
            
        default:
            break;
    }
    
    return true;
}

#pragma mark CloseEmbeddedWebview Method
- (void)closeEmbeddedWebView:(CDVInvokedUrlCommand *)command {
    //Simply reset the variables removing the UI from the view if exists and send success callback
    [self resetPluginVariables];
    [self sendSuccessCallBack:command];
    
}

#pragma mark Webview History Back Method
- (void)webviewHistoryBack:(CDVInvokedUrlCommand *)command {
    if (nativeWebView != nil) {
        [self historyBack];
        [self sendSuccessCallBack:command];
    } else {
        [self sendErrorCallBack:command withMessage:@"No webview has been found. Create a new one before to call the history back method"];
    }
}

#pragma mark Webview History Forward Method
- (void)webviewHistoryForward:(CDVInvokedUrlCommand *)command {
    if (nativeWebView != nil) {
        [self historyForward];
        [self sendSuccessCallBack:command];
    } else {
        [self sendErrorCallBack:command withMessage:@"No webview has been found. Create a new one before to call the history forward method"];
    }
}

#pragma mark CallBack management
- (void) sendSuccessCallBack:(CDVInvokedUrlCommand *)command {
    NSMutableDictionary *callbackDictionary = [[NSMutableDictionary alloc] init];
    callbackDictionary[@"result"] = @"success";

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:callbackDictionary];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) sendErrorCallBack:(CDVInvokedUrlCommand *)command withMessage:(NSString *)message {
    NSMutableDictionary *callbackDictionary = [[NSMutableDictionary alloc] init];
    callbackDictionary[@"result"] = @"error";
    callbackDictionary[@"reason"] = message;

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:callbackDictionary];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
