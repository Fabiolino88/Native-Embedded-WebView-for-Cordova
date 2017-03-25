# Native-Embedded-WebView-for-Cordova
Cordova Embedded WebView plugin - to add a native webview inside your cordova app

iOS platform available - Android coming soon

Hi guys, if you need to show a link in your apps, make it looking like is embedded withouth present any other modal view or controller, than this plugin is probably for you.
Giving to the plugin the new sizes of the frame and a url address, it will create your new UIWebView.


![alt tag](https://github.com/Fabiolino88/Native-Embedded-WebView-for-Cordova/blob/master/Example.png)


```
cordova plugin add https://github.com/Fabiolino88/Native-Embedded-WebView-for-Cordova
```


If you are using angular 2 and typescripc remember to install typings and add cordova to it.
Open the terminal and run:

```
npm install -g typings

typings install dt~cordova --save --global
```

than in your ts file add: 

```
declare var cordova:any;
```

and after you can finally add the webview to your view
(the sizes and position needs to be in pixel)

```
var embeddedWebview: any = cordova.plugins.EmbeddedWebView;
var optionsObj = {
    webview_width: 375,
    webview_height: 400,
    webview_position_x: 0,
    webview_position_y: 64,
    url: 'YOUR URL',
    showIosToolBar: true,  //This will show a toolbar at the bottom of the webview with back and forward button
    toolBarStyle: "dark", //You can use dark or light style for the toolbar
    showSpinnerWhileLoading: true  //If you want to show a spinner while is loading the pages
};

//Open the webview
embeddedWebview.showEmbeddedWebView(function(success: any){
      console.log('Printing on success: ', success);
    }, function(error: any) {
      console.log('Printing on error: ', error);
    }, optObj);
    

//Remove the webview from the view
embeddedWebView.closeEmbeddedWebView(function(success) {
        console.log('WebView removed with success');
    }, function(error: any) {
        console.log('WebView not removed with error: ', error);
    });
    

//History Back
embeddedWebview.webviewHistoryBack(function(success) {
        console.log('History Back success: ', success);
    }, function(error) {
        console.log('History Back Error: ', error);
    });
    

//History Forward
embeddedWebview.webviewHistoryForward(function(success) {
        console.log('History Forward success: ', success);
    }, function(error) {
        console.log('History Forward Error: ', error);
    });
```
