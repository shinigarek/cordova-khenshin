#import <Cordova/CDVPlugin.h>

@interface KhenshinPlugin : CDVPlugin

- (void)startByPaymentId:(CDVInvokedUrlCommand*)command;

- (void)startByAutomatonId:(CDVInvokedUrlCommand*)command;

- (UIColor *)colorFromHexString:(NSString* )hexString;

@end