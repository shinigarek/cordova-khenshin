#import "KhenshinPlugin.h"
#import <Cordova/CDVPlugin.h>
#import <khenshin/khenshin.h>
#import "PaymentProcessHeader.h"

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

- (void)finishLaunching:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] setBool:NO
                                            forKey:@"KH_SHOW_HOW_IT_WORKS"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [KhenshinInterface initWithNavigationBarCenteredLogo:[[UIImage alloc] init]
                               NavigationBarLeftSideLogo:[[UIImage alloc] init]
                                         automatonAPIURL:[[NSURL alloc] initWithString:@"https://cmr.browser2app.com/api/automata/"]
                                           cerebroAPIURL:[[NSURL alloc] initWithString:@"https://cmr.browser2app.com/api/automata/"]
                                           processHeader:(UIView<ProcessHeader>*)[self processHeader]
                                          processFailure:nil
                                          processSuccess:nil
                                          processWarning:nil
                                  allowCredentialsSaving:YES
                                         mainButtonStyle:KHMainButtonFatOnForm
                         hideWebAddressInformationInForm:NO
                                useBarCenteredLogoInForm:NO
                                          principalColor:[UIColor lightGrayColor]
                                    darkerPrincipalColor:[UIColor darkGrayColor]
                                          secondaryColor:[UIColor redColor]
                                   navigationBarTextTint:[UIColor whiteColor]
                                                    font:[UIFont fontWithName:@"Avenir Next Condensed" size:15.0f]];
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
