//
//  FPPopoverController.h
//
//  Created by Alvise Susmel on 1/5/12.
//  Copyright (c) 2012 Fifty Pixels Ltd. All rights reserved.
//
//  https://github.com/50pixels/FPPopover
//
// Updated by Jock Findlay
// https://github.com/kotikan/FPPopover

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "FPPopoverView.h"
#import "FPTouchView.h"

@class FPPopoverController;

/**
* The interface to receive events about popovers being shown and dismissed.
*/
@protocol FPPopoverControllerDelegate <NSObject>

@optional

- (BOOL)popoverControllerWillDismissPopover:(FPPopoverController *)popoverController;

/**
* Called when a popover finishes closing.
*
* @param popoverController The popover that has closed.
*/
- (void)popoverControllerDidDismissPopover:(FPPopoverController *)popoverController;

/**
* Called by existing popovers when a new popover is shown.
*
* @param newPopoverController The new popover being shown.
* @param visiblePopoverController A popover that is already visible.
*/
- (void)presentedNewPopoverController:(FPPopoverController *)newPopoverController 
          shouldDismissVisiblePopover:(FPPopoverController*)visiblePopoverController;
@end

/**
* A view-controller that mimics the behaviour of UIPopoverController but with more flexible styling options.
*/
@interface FPPopoverController : UIViewController<UINavigationControllerDelegate>
{
    FPTouchView *_touchView;
    FPPopoverView *_contentView;
    UIViewController *_viewController;
    UIWindow *_window;
    UIView *_parentView;
    UIView *_fromView;
    UIDeviceOrientation _deviceOrientation;
}

/**
* A delegate that will be informed of popovers being shown and dismissed.
*/
@property(nonatomic,assign) id<FPPopoverControllerDelegate> delegate;

/** @brief FPPopoverArrowDirectionAny, FPPopoverArrowDirectionVertical or FPPopoverArrowDirectionHorizontal for automatic arrow direction.
 **/
@property(nonatomic,assign) FPPopoverArrowDirection arrowDirection;

/**
* The size of the content displayed inside the popover
*/
@property(nonatomic,assign) CGSize contentSize;

/**
* The point that the popover is pointing to.
*/
@property(nonatomic,assign) CGPoint origin;

/** @brief The tint of the popover. **/
@property(nonatomic,assign) FPPopoverTint tint;

/**
 * @brief Whether to close the popover when a tap is detected that is outside the popover.
 */
 @property (nonatomic, assign) BOOL closesOnTapOff;

/**
 * @brief Whether to close the popover when a tap is detected that is inside the popover.
 */
@property (nonatomic, assign) BOOL closesOnTapOn;

/**
 * @brief The color to set the area not covered by the popover.
 */
@property (nonatomic, retain) UIColor *backgroundDarkenerColor;

/**
 * @brief A view to keep in front of the background view but behind the popover
 */
@property (nonatomic, retain) UIView *inFrontView;

@property (nonatomic, readonly) BOOL popoverVisible;

/**
 * @brief Sets the size of the popover including the borders and arrow.
 */
@property (nonatomic, assign) CGSize popoverContentSize;

/** @brief Initialize the popover with the content view controller
 **/
-(id)initWithViewController:(UIViewController*)viewController;

/**
* Sets the popover style. This will change all aspects that a style object covers. Causes a redraw to occur.
*/
- (void)setStyle:(FPPopoverStyle*)style;

/** @brief Presenting the popover from a specified view **/
-(void)presentPopoverFromView:(UIView*)fromView;

/** @brief Presenting the popover from a specified point **/
-(void)presentPopoverFromPoint:(CGPoint)fromPoint;

/** @brief Dismiss the popover **/
-(void)dismissPopoverAnimated:(BOOL)animated;

/**
 * The view-controller that this popover controller was created with.
 */
- (UIViewController *)contentViewController;

/**
 * If the content view controller implements the FPPopoverAccessoriesProtocol, the accessories on the popovers bars
 * will be updated.
 */
- (void)updateAccessories;

@end
