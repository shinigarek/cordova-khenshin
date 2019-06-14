#import "KhenshinPlugin.h"
#import <Cordova/CDVPlugin.h>
#import <khenshin/khenshin.h>
#import "PaymentProcessHeader.h"
#import "AFNetworking.h"

@implementation KhenshinPlugin

- (void)pluginInitialize
{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];

}

- (UIView*) processHeader {

    PaymentProcessHeader *processHeaderObj =    [[[NSBundle mainBundle] loadNibNamed:@"PaymentProcessHeader"
                                                                               owner:self
                                                                             options:nil]
                                                 objectAtIndex:0];

    //    return nil;
    return processHeaderObj;
}

- (UIColor *)colorFromHexString:(NSString* )hexString {
   unsigned rgbValue = 0;
   NSScanner *scanner = [NSScanner scannerWithString:hexString];
   [scanner setScanLocation:1]; // bypass '#' character
   [scanner scanHexInt:&rgbValue];
   return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void)finishLaunching:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] setBool:NO
                                            forKey:@"KH_SHOW_HOW_IT_WORKS"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [KhenshinInterface initWithBuilderBlock:^(KhenshinBuilder *builder){
        builder.APIUrl = @"https://khipu.com/app/enc/";
        builder.barCenteredLogo = [UIImage imageNamed:@"Bar Logo"];
        builder.barLeftSideLogo = [[UIImage alloc] init];
        builder.processHeader = [self processHeader];
        builder.skipExitPage = YES;
        builder.keepCookies = YES;
        builder.mainButtonStyle = KHMainButtonFatOnForm;

        builder.cellPadding = 30;
        builder.hideWebAddressInformationInForm = TRUE;

        builder.cellSeparatorHeight = 2.f;
        builder.barTintColor = [self colorFromHexString:@"#911c80"];
        builder.navigationBarTextTint = [self colorFromHexString:@"#ffffff"];
         builder.textColorHex = @"#ff00ff";
        builder.principalColor = [self colorFromHexString:@"#911c80"];
        builder.secondaryColor = [self colorFromHexString:@"#ffffff"];
        builder.darkerPrincipalColor = [self colorFromHexString:@"#911c80"];

        builder.allowCredentialsSaving = YES;
    }];
}

- (void)startByPaymentId:(CDVInvokedUrlCommand*)command
{


    [KhenshinInterface startEngineWithPaymentExternalId:[command.arguments objectAtIndex:0]
                                         userIdentifier:@""
                                      isExternalPayment:true
                                                success:^(NSURL *returnURL) {
                                                    CDVPluginResult* pluginResult = nil;
                                                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                                                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                                }
                                                failure:^(NSURL *returnURL) {
                                                    CDVPluginResult* pluginResult = nil;
                                                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                                                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                                }
                                               animated:false];
}

- (void)startByAutomatonId:(CDVInvokedUrlCommand*)command
{

    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] initWithCapacity:20];
    for(int i = 1; i < [command.arguments count] ; i ++) {
        NSArray* kv = [[command.arguments objectAtIndex:i] componentsSeparatedByString:@":"];
        [parameters setObject:[kv objectAtIndex:1] forKey:[kv objectAtIndex:0]];
    }

    [KhenshinInterface startEngineWithAutomatonId:[command.arguments objectAtIndex:0]
                                         animated:false
                                       parameters:parameters
                                   userIdentifier:@""
                                          success:^(NSURL *returnURL) {
                                              CDVPluginResult* pluginResult = nil;
                                              pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                                              [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                          }
                                          failure:^(NSURL *returnURL) {
                                              CDVPluginResult* pluginResult = nil;
                                              pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                                              [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                          }];

}

@end
