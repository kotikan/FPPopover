//
//  UINavigationController+FPPopoverAccessories.m
//
//  Created by Jock Findlay on 08/11/2012.
//
//

#import "UINavigationController+FPPopoverAccessories.h"

#include <objc/runtime.h>

static char leftBarButtonKey;
static char rightBarButtonKey;

static char leftButtonCopyKey;
static char rightButtonCopyKey;

// http://stackoverflow.com/a/5183349
static void copyButtonActions(UIButton *src, UIButton *dst) {
    UIControlEvents controlEvents = src.allControlEvents;
    NSSet *targets = src.allTargets;
    
    for (UIControlEvents controlEvent = 1; controlEvent != 0; controlEvent <<= 1) {
        if ((controlEvent & controlEvents) != 0) {
            for (id target in targets) {
                NSArray *actions = [src actionsForTarget:target forControlEvent:controlEvent];
                for (NSString *actionName in actions) {
                    SEL action = NSSelectorFromString(actionName);
                    [dst addTarget:target action:action forControlEvents:controlEvent];
                }
            }
        }
    }
}

// http://stackoverflow.com/a/1093043
static UIButton *copyButton(UIButton *button) {
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject: button];
    UIButton *buttonCopy = [NSKeyedUnarchiver unarchiveObjectWithData: archivedData];
    copyButtonActions(button, buttonCopy);

    return buttonCopy;
}

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
    if ([self.topViewController conformsToProtocol:@protocol(FPPopoverAccessoriesProtocol)] &&
        [self.topViewController respondsToSelector:@selector(leftTopBarButton)]) {
        return [(UIViewController<FPPopoverAccessoriesProtocol> *)self.topViewController leftTopBarButton];
    } else {
        return [self copyAndCacheBarButton:self.topViewController.navigationItem.leftBarButtonItem
                              barButtonKey:&leftBarButtonKey
                             buttonCopyKey:&leftButtonCopyKey];
    }
}

/**
 * A button that will be placed at the right side of the top bar of the popover.
 */
- (UIButton *)rightTopBarButton {
    if ([self.topViewController conformsToProtocol:@protocol(FPPopoverAccessoriesProtocol)] &&
        [self.topViewController respondsToSelector:@selector(rightTopBarButton)]) {
        return [(UIViewController<FPPopoverAccessoriesProtocol> *)self.topViewController rightTopBarButton];
    } else {
        return [self copyAndCacheBarButton:self.topViewController.navigationItem.rightBarButtonItem
                              barButtonKey:&rightBarButtonKey
                             buttonCopyKey:&rightButtonCopyKey];
    }
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

#pragma mark Private

- (UIButton *)copyAndCacheBarButton:(UIBarButtonItem *)barButtonItem barButtonKey:(const void *)barButtonKey buttonCopyKey:(const void *)buttonCopyKey {
    // Don't attempt to copy from/to things which aren't buttons.
    // NOTE:
    // FPPopoverView's assertion that right bar button items' custom views are buttons is not correct.
    if (![barButtonItem.customView isKindOfClass:[UIButton class]]) {
        return (UIButton *)barButtonItem.customView;
    }
    
    UIButton *oldButton = objc_getAssociatedObject(self, barButtonKey);
    UIButton *newButton = (UIButton*)(barButtonItem.customView);
    
    if (oldButton != newButton) {
        UIButton *buttonCopy = copyButton(newButton);
        
        objc_setAssociatedObject(self, barButtonKey, newButton, OBJC_ASSOCIATION_RETAIN);
        objc_setAssociatedObject(self, buttonCopyKey, buttonCopy, OBJC_ASSOCIATION_RETAIN);
        
        return buttonCopy;
    } else {
        UIButton *buttonCopy = objc_getAssociatedObject(self, buttonCopyKey);
        
        return buttonCopy;
    }
}

@end
