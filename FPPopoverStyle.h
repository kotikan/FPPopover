//
// FPPopoverStyle
// Skyscanner
//
// Created by jock on 09/09/2012.
//
// https://github.com/kotikan/FPPopover

#import <Foundation/Foundation.h>

#import "FPTouchView.h"

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

/**
* An inset for the content of the popover so that a part of the frameView is visible.
*/
- (CGSize)contentFrameInset;

/**
* The color of the title text.
*/
- (UIColor*)titleColor;

/**
* The color of the title text shadow color.
*/
- (UIColor*)titleShadowColor;

/**
* The offset for the title shadow.
*/
- (CGSize)titleShadowOffset;

/**
* The font of the title.
*/
- (UIFont*)titleFont;

/**
* The default color of the popover border. If there are top and bottom gradients these will be drawn instead of this
* color.
*/
- (UIColor*)borderColor;

/**
 * A gradient for the border as an alternative to solid color.
 */
- (CGGradientRef)borderGradient;

/**
* The width of the border around the popover. Also the gap between the top of the popover and the title (if any) and
* the gap between the edge of the popover and any buttons.
*/
- (CGFloat)borderWidth;

/**
* The radius of the popover corner
*/
- (CGFloat)cornerRadius;

/**
* The radius of the corners of the content view
*/
- (CGFloat)contentCornerRadius;

/**
* A gradient for the top bar when the arrow is protruding from the top edge. Required.
*/
- (CGGradientRef)topBarGradientForTopArrow;

/**
* A gradient for the top bar when the arrow is protruding from any edge other than the top. Required.
*/
- (CGGradientRef)topBarGradientForNonTopArrow;

/**
* A gradient for the bottom bar when the arrow is protruding from any edge other than the bottom. If
* bottomBarGradientHeight > 0, this is required.
*/
- (CGGradientRef)bottomBarGradientForNonBottomArrow;

/**
* A gradient for the bottom bar when the arrow is protruding from the bottom edge. If
* bottomBarGradientHeight > 0, this is required.
*/
- (CGGradientRef)bottomBarGradientForBottomArrow;

/**
* The height of the top bar (excluding the arrow)
*/
- (CGFloat)topBarHeight;

/**
* The height of the top bar gradient. The top bar gradient is drawn from the top of the view downwards.
*/
- (CGFloat)topBarGradientHeight;

/**
* The height of the bottom bar (excluding the arrow)
*/
- (CGFloat)bottomBarHeight;

/**
* The height of the bottom bar gradient. The bottom bar gradient is drawn from the end of the content-view downwards.
* Return 0 for no bottom bar gradient.
*/
- (CGFloat)bottomBarGradientHeight;

/**
* The color of the outline drawn around the outside of the popover. Can be nil for no outer border.
*/
- (UIColor*)outerBorderColor;

/**
* The width of the outline drawn around the outside of the popover.
*/
- (CGFloat)outerBorderWidth;

/**
* The color of the outline drawn 2-pixels in from the outside of the popover. Can be nil for no inner border.
*/
- (UIColor*)innerBorderColor;

/**
* The width of the outline drawn 2-pixels in from the outside of the popover.
*/
- (CGFloat)innerBorderWidth;

/**
* The color of the highlight applied to the top edge. Can be nil for no highlight. Does not work with an inner-border.
*/
- (UIColor*)topEdgeHighlightColor;

/**
* The width of the highlight applied to the top edge.
*/
- (CGFloat)topEdgeHighlightWidth;

/**
* The color of the rectangular frame around the content (outer frame). Can be nil for no frame.
*/
- (UIColor*)outerContentFrameColor;

/**
* The width of the rectangular frame around the content (outer frame).
*/
- (CGFloat)outerContentFrameWidth;

/**
* The color of the rectangular frame around the content (inner frame). Can be nil for no frame.
*/
- (UIColor*)innerContentFrameColor;

/**
* The width of the rectangular frame around the content (inner frame).
*/
- (CGFloat)innerContentFrameWidth;

/**
 * A view that will be drawn on top of the content-view-controller
 */
- (UIView*)overlayView;

- (void)animateWithPortion:(CGFloat)portion;

- (UIColor*)shadowColor;

- (CGFloat)shadowRadius;

- (CGFloat)shadowOpacity;

- (BOOL)hasTapOffNoCloseAnimation;

- (CGFloat)topBarButtonOuterPadding;

@end