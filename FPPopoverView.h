//
//  FPPopoverView.h
//
//  Created by Alvise Susmel on 1/4/12.
//  Copyright (c) 2012 Fifty Pixels Ltd. All rights reserved.
//
//  https://github.com/50pixels/FPPopover
//
// Updated by Jock Findlay
// https://github.com/kotikan/FPPopover

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class FPPopoverStyle;

/**
* Flags to indicate arrow direction and utility flag-groupings.
*/
typedef enum {
    FPPopoverArrowDirectionUp = 1UL << 0,
    FPPopoverArrowDirectionDown = 1UL << 1,
    FPPopoverArrowDirectionLeft = 1UL << 2,
    FPPopoverArrowDirectionRight = 1UL << 3,

    FPPopoverArrowDirectionVertical = FPPopoverArrowDirectionUp | FPPopoverArrowDirectionDown,
    FPPopoverArrowDirectionHorizontal = FPPopoverArrowDirectionLeft | FPPopoverArrowDirectionRight,
    
    FPPopoverArrowDirectionAny = FPPopoverArrowDirectionUp | FPPopoverArrowDirectionDown | 
    FPPopoverArrowDirectionLeft | FPPopoverArrowDirectionRight
    
} FPPopoverArrowDirection;


#define FPPopoverArrowDirectionIsVertical(direction)    ((direction) == FPPopoverArrowDirectionVertical || (direction) == FPPopoverArrowDirectionUp || (direction) == FPPopoverArrowDirectionDown)

#define FPPopoverArrowDirectionIsHorizontal(direction)    ((direction) == FPPopoverArrowDirectionHorizontal || (direction) == FPPopoverArrowDirectionLeft || (direction) == FPPopoverArrowDirectionRight)

/**
* Simple styling enumeration that can be used to easily set one of the default styles. Should be deprecated in
* favour of styles?
*/
typedef enum {
    FPPopoverBlackTint = 1UL << 0, // default
    FPPopoverLightGrayTint = 1UL << 1,
    FPPopoverGreenTint = 1UL << 2,
    FPPopoverRedTint = 1UL << 3,
    FPPopoverDefaultTint = FPPopoverBlackTint
} FPPopoverTint;

/**
* The styled popover view that contains the content, handles rendering and arrows.
*/
@interface FPPopoverView : UIView
{
    //default FPPopoverArrowDirectionUp
    FPPopoverArrowDirection _arrowDirection;
    UIView *_contentView;
    UILabel *_titleLabel;
}

/**
* The title that appears at the top of the popover. This is copied from the title of the view-controller that is passed
* into FPPopoverViewController::initWithViewController. Set to nil for no title; in this case the top bar will be the
* height of the style borderWidth.
*/
@property(nonatomic,retain) NSString *title;

/**
* The origin of this view relative to the content view.
*/
@property(nonatomic,assign) CGPoint relativeOrigin;

/**
* The color of the popover. Setting this will set the style to one of the default styles.
*/
@property(nonatomic,assign) FPPopoverTint tint;

/**
* The appearance of the popover.
*/
@property(nonatomic,retain) FPPopoverStyle *style;

/**
* Sets the arrow to be protruding from a specific edge.
*/
- (void)setArrowDirection:(FPPopoverArrowDirection)arrowDirection;

/**
* The edge that the arrow is protruding from.
*/
- (FPPopoverArrowDirection)arrowDirection;

/**
* Sets the view to be drawn inside the popover.
*/
- (void)setContentView:(UIView*)contentView;

/**
* Sets a button on the left side of the popover alongside the title. Assumes the size of the button is appropriate
* for the popover.
* BUG: Assumes there is a title.
*/
- (void)setLeftButton:(UIButton*)button;

/**
* Sets a button on the right side of the popover alongside the title. Assumes the size of the button is appropriate
* for the popover.
* BUG: Assumes there is a title.
*/
- (void)setRightButton:(UIButton*)button;

/**
 * Sets a view in the centre of the popover where the title would be. Assumes the size of the view is appropriate
 * for the popover. Will cover the title.
 */
- (void)setTopCentreView:(UIView*)view;

/**
* Arranges an array of buttons in a single line along the bottom of the popover. Assumes the sizes of the buttons are
* appropriate for the size of the popover and the height of the bottom bar.
*
* @param buttons An array of UIButton buttons.
*/
- (void)setBottomBarButtons:(NSArray *)buttons;

@end
