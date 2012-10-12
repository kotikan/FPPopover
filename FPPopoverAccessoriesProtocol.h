//
// FPPopoverAccessoriesProtocol
// Skyscanner
//
// Created by jock on 18/09/2012.
//
// https://github.com/kotikan/FPPopover

@protocol FPPopoverAccessoriesProtocol <NSObject>

@optional

/**
 * An array of buttons that will be spaced evenly along the bottom bar of the popover. Assumes that the bottom bar
 * height is large enough to fit the buttons.
 */
- (NSArray *)bottomBarButtons;

/**
 * A button that will be placed at the left side of the top bar of the popover.
 */
- (UIButton *)leftTopBarButton;

/**
 * A button that will be placed at the right side of the top bar of the popover.
 */
- (UIButton *)rightTopBarButton;

/**
 * A view that will be placed in the centre of the top bar of the popover.
 */
- (UIView *)centreTopView;

@end