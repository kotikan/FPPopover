//
// FPPopoverBlackStyle
// Skyscanner
//
// Created by jock on 09/09/2012.
//
// https://github.com/kotikan/FPPopover

#import "FPPopoverBlackStyle.h"


@implementation FPPopoverBlackStyle {
    CGGradientRef topBarGradientForTopArrow;
    CGGradientRef topBarGradientForBottomArrow;
}

- (id)init {
    self = [super init];
    if (self) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

        // make a gradient
        CGFloat colors[8];
        colors[0] = colors[1] = colors[2] = 0.6;
        colors[4] = colors[5] = colors[6] = 0.1;
        colors[3] = colors[7] = 1.0;
        topBarGradientForTopArrow = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
        colors[0] = colors[1] = colors[2] = 0.4;
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