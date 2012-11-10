//
//  UINavigationController+FPPopoverAccessories.m
//
//  Created by Jock Findlay on 08/11/2012.
//
//

#import "UINavigationController+FPPopoverAccessories.h"

@implementation UINavigationController (FPPopoverAccessories)

- (NSArray *)bottomBarButtons {
    if ([self.topViewController conformsToProtocol:@protocol(FPPopoverAccessoriesProtocol)] &&
        [self.topViewController respondsToSelector:@selector(bottomBarButtons)]) {
        return [(UIViewController<FPPopoverAccessoriesProtocol> *)self.topViewController bottomBarButtons];
    } else {
        return nil;
    }
}

/**
 * A button that will be placed at the left side of the top bar of the popover.
 */
- (UIButton *)leftTopBarButton {
    return (UIButton*)(self.topViewController.navigationItem.leftBarButtonItem.customView);
}

/**
 * A button that will be placed at the right side of the top bar of the popover.
 */
- (UIButton *)rightTopBarButton {
    return (UIButton*)(self.topViewController.navigationItem.rightBarButtonItem.customView);
}

/**
 * A view that will be placed in the centre of the top bar of the popover.
 */
- (UIView *)centreTopView {
    if ([self.topViewController conformsToProtocol:@protocol(FPPopoverAccessoriesProtocol)] &&
        [self.topViewController respondsToSelector:@selector(centreTopView)]) {
        return [(UIViewController<FPPopoverAccessoriesProtocol> *)self.topViewController centreTopView];
    } else {
        return nil;
    }
}

@end
