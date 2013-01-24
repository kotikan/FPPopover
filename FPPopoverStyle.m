//
// FPPopoverStyle
// Skyscanner
//
// Created by jock on 09/09/2012.
//

#import "FPPopoverStyle.h"


@implementation FPPopoverStyle {

}

- (CGFloat)arrowHeight {
    return 20.0f;
}

- (CGFloat)arrowBaseWidth {
    return 20.0f;
}

- (UIView*)frameView {
    return nil;
}

- (CGSize)contentFrameInset {
    return CGSizeZero;
}

- (UIColor*)titleColor {
    return [UIColor whiteColor];
}

- (UIColor*)titleShadowColor {
    return [UIColor clearColor];
}

- (UIColor*)borderColor {
    return [UIColor blackColor];
}

- (CGGradientRef)borderGradient {
    return nil;
}

- (CGFloat)borderWidth {
    return 10.0f;
}

- (CGFloat)cornerRadius {
    return 10.0f;
}

- (CGSize)titleShadowOffset {
    return CGSizeZero;
}

- (UIFont*)titleFont {
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
}

- (CGFloat)contentCornerRadius {
    return 0.0f;
}

- (CGGradientRef)topBarGradientForTopArrow {
    return nil;
}

- (CGGradientRef)topBarGradientForNonTopArrow {
    return nil;
}

- (CGGradientRef)bottomBarGradientForNonBottomArrow {
    return nil;
}

- (CGGradientRef)bottomBarGradientForBottomArrow {
    return nil;
}

- (CGFloat)topBarHeight {
    return 40.0f;
}

- (CGFloat)topBarGradientHeight {
    return 0.0f;
}

- (CGFloat)bottomBarHeight {
    return 10.0f;
}

- (CGFloat)bottomBarGradientHeight {
    return 0.0f;
}

- (UIColor*)outerBorderColor {
    return [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.0f];
}

- (CGFloat)outerBorderWidth {
    return 1.0f;
}

- (UIColor*)topEdgeHighlightColor {
    return nil;
}

- (CGFloat)topEdgeHighlightWidth {
    return 0.0f;
}

- (UIColor*)innerBorderColor {
    return [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f];
}

- (CGFloat)innerBorderWidth {
    return 1.0f;
}

- (UIColor*)outerContentFrameColor {
    return [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.0f];
}

- (CGFloat)outerContentFrameWidth {
    return 1.0f;
}

- (UIColor*)innerContentFrameColor {
    return [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f];
}

- (CGFloat)innerContentFrameWidth {
    return 1.0f;
}

- (UIView*)overlayView {
    return nil;
}

- (void)animateWithPortion:(CGFloat)portion {
    
}

- (UIColor*)shadowColor {
    return [UIColor blackColor];
}

- (CGFloat)shadowRadius {
    return 5.0f;
}

- (CGFloat)shadowOpacity {
    return 0.7f;
}

@end
