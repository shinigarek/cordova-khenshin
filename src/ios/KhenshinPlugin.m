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

- (void)finishLaunching:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] setBool:NO
                                            forKey:@"KH_SHOW_HOW_IT_WORKS"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [KhenshinInterface initWithNavigationBarCenteredLogo:[[UIImage alloc] init]
                               NavigationBarLeftSideLogo:[[UIImage alloc] init]
                                         automatonAPIURL:[[NSURL alloc] initWithString:@"https://khipu.com/app/2.0/"]
                                           cerebroAPIURL:[[NSURL alloc] initWithString:@"https://khipu.com/cerebro/"]
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
                                                    font:nil];
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

- (void)createPayment:(CDVInvokedUrlCommand*)command
{

    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] initWithCapacity:20];
    for(int i = 0; i < [command.arguments count] ; i ++) {
        NSArray* kv = [[command.arguments objectAtIndex:i] componentsSeparatedByString:@":"];
        [parameters setObject:[kv objectAtIndex:1] forKey:[kv objectAtIndex:0]];
    }


    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[[NSURL alloc] initWithString:@"https://khipu.com/ripley-fitting/api/"]];
	manager.responseSerializer = [AFJSONResponseSerializer serializer];

	[manager POST:@"payment/create"
	  parameters:parameters
		progress:nil
		 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
			 NSLog(@"responseObject==%@",responseObject);

			 [KhenshinInterface startEngineWithPaymentExternalId:[responseObject valueForKeyPath:@"paymentId"]
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
		 failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
			 NSLog(@"error: %@", error);
		 }];







}

@end
