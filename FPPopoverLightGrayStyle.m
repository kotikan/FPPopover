//
//  FPPopoverLightGrayStyle.m
//  Skyscanner
//
//  Created by Jock Findlay on 09/09/2012.
//
//

#import "FPPopoverLightGrayStyle.h"

@implementation FPPopoverLightGrayStyle {
    CGGradientRef topBarGradientForTopArrow;
    CGGradientRef topBarGradientForBottomArrow;
}

- (id)init {
    self = [super init];
    if (self) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        // make a gradient
        CGFloat colors[8];
        colors[0] = colors[1] = colors[2] = 0.8;
        colors[4] = colors[5] = colors[6] = 0.3;
        colors[3] = colors[7] = 1.0;
        topBarGradientForTopArrow = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
        colors[0] = colors[1] = colors[2] = 0.6;
        colors[4] = colors[5] = colors[6] = 0.1;
        topBarGradientForBottomArrow = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
        CFRelease(colorSpace);
    }
    return self;
}

- (CGGradientRef)topBarGradientForTopArrow {
    return topBarGradientForTopArrow;
}

- (CGGradientRef)topBarGradientForNonTopArrow {
    return topBarGradientForBottomArrow;
}

- (CGFloat)topBarGradientHeight {
    return 20.0f;
}

- (void)dealloc {
    CGGradientRelease(topBarGradientForTopArrow);
    CGGradientRelease(topBarGradientForBottomArrow);
    [super dealloc];
}

@end