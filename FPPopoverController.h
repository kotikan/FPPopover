//
//  FPPopoverController.h
//
//  Created by Alvise Susmel on 1/5/12.
//  Copyright (c) 2012 Fifty Pixels Ltd. All rights reserved.
//
//  https://github.com/50pixels/FPPopover

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "FPPopoverView.h"
#import "FPTouchView.h"

@class FPPopoverController;
@protocol FPPopoverControllerDelegate <NSObject>

@optional
- (void)popoverControllerDidDismissPopover:(FPPopoverController *)popoverController;
- (void)presentedNewPopoverController:(FPPopoverController *)newPopoverController 
          shouldDismissVisiblePopover:(FPPopoverController*)visiblePopoverController;
@end

@interface FPPopoverController : UIViewController
{
    FPTouchView *_touchView;
    FPPopoverView *_contentView;
    UIViewController *_viewController;
    UIWindow *_window;
    UIView *_parentView;
    UIView *_fromView;
    UIDeviceOrientation _deviceOrientation;
}
@property(nonatomic,assign) id<FPPopoverControllerDelegate> delegate;
/** @brief FPPopoverArrowDirectionAny, FPPopoverArrowDirectionVertical or FPPopoverArrowDirectionHorizontal for automatic arrow direction.
 **/
@property(nonatomic,assign) FPPopoverArrowDirection arrowDirection;

@property(nonatomic,assign) CGSize contentSize;
@property(nonatomic,assign) CGPoint origin;

/** @brief The tint of the popover. **/
@property(nonatomic,assign) FPPopoverTint tint;

/**
 * @brief Whether to close the popover when a tap is detected that is outside the popover.
 */
 @property (nonatomic, assign) BOOL closesOnTapOff;

/**
 * @brief The color to set the area not covered by the popover.
 */
@property (nonatomic, retain) UIColor *backgroundDarkenerColor;

/**
 * @brief A view to keep in front of the background view but behind the popover
 */
@property (nonatomic, retain) UIView *inFrontView;

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





@end
