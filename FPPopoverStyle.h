//
// FPPopoverStyle
// Skyscanner
//
// Created by jock on 09/09/2012.
//

#import <Foundation/Foundation.h>


@interface FPPopoverStyle : NSObject

/**
* Height of the arrow in points.
*/
- (CGFloat)arrowHeight;

/**
* Width of the arrow where it meets the edge of the popover.
*/
- (CGFloat)arrowBaseWidth;

/**
* A view that will surround the content view using the content-views background color.
*/
- (UIView*)frameView;
- (CGSize)contentFrameInset;
- (UIColor*)titleColor;
- (UIColor*)titleShadowColor;
- (UIColor*)borderColor;
- (CGFloat)borderWidth;
- (CGFloat)cornerRadius;
- (CGSize)titleShadowOffset;
- (UIFont*)titleFont;
- (CGFloat)contentCornerRadius;
- (CGGradientRef)topBarGradientForTopArrow;
- (CGGradientRef)topBarGradientForBottomArrow;
- (CGGradientRef)bottomBarGradientForTopArrow;
- (CGGradientRef)bottomBarGradientForBottomArrow;
- (CGFloat)topBarHeight;
- (CGFloat)topBarGradientHeight;
- (CGFloat)bottomBarHeight;
- (CGFloat)bottomBarGradientHeight;
- (UIColor*)outerBorderColor;
- (CGFloat)outerBorderWidth;
- (UIColor*)topEdgeHighlightColor;
- (CGFloat)topEdgeHighlightWidth;
- (UIColor*)innerBorderColor;
- (CGFloat)innerBorderWidth;
- (UIColor*)outerContentFrameColor;
- (CGFloat)outerContentFrameWidth;
- (UIColor*)innerContentFrameColor;
- (CGFloat)innerContentFrameWidth;

@end