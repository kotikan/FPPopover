//
//  FPPopoverRedStyle.m
//  Skyscanner
//
//  Created by Jock Findlay on 09/09/2012.
//
//

#import "FPPopoverRedStyle.h"

@implementation FPPopoverRedStyle {
    CGGradientRef topBarGradientForTopArrow;
    CGGradientRef topBarGradientForBottomArrow;
}

- (id)init {
    self = [super init];
    if (self) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        // make a gradient
        CGFloat colors[8];
        colors[0] = 0.72; colors[1] = 0.35; colors[2] = 0.32;
        colors[4] = 0.36; colors[5] = 0.0;  colors[6] = 0.09;
        colors[3] = colors[7] = 1.0;
        topBarGradientForTopArrow = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
        colors[0] = 0.82; colors[1] = 0.45; colors[2] = 0.42;
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