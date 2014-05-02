//
//  FPPopoverController.m
//
//  Created by Alvise Susmel on 1/5/12.
//  Copyright (c) 2012 Fifty Pixels Ltd. All rights reserved.
//
//  https://github.com/50pixels/FPPopover
//
// Updated by Jock Findlay
// https://github.com/kotikan/FPPopover

#import "FPPopoverController.h"
#import "FPPopoverAccessoriesProtocol.h"
#import "FPPopoverStyle.h"

@interface FPPopoverController(Private)
-(CGPoint)originFromView:(UIView*)fromView;


-(CGFloat)parentWidth;
-(CGFloat)parentHeight;

#pragma mark Space management
/* This methods help the controller to found a proper way to display the view.
 * If the "from point" will be on the left, the arrow will be on the left and the 
 * view will be move on the right of the from point.
 */
-(CGRect)bestViewFrameForFromPoint:(CGPoint)point;

-(CGRect)bestArrowDirectionAndFrameFromView:(UIView*)v;

@property (nonatomic, readwrite) BOOL popoverVisible;

@end

@implementation FPPopoverController {
    UIView *backgroundDarkener;
    UIView *inFrontViewsParentView;
    CGRect inFrontViewsFrame;
    CGSize contentSizeWithoutKeyboard;
    CGPoint originToMaintain;
    BOOL keyboardVisible;
    BOOL dismissalAnimationInProgress;
    BOOL maintainOrigin;
}

@synthesize delegate = _delegate;
@synthesize contentSize = _contentSize;
@synthesize origin = _origin;
@synthesize arrowDirection = _arrowDirection;
@synthesize tint = _tint;
@synthesize backgroundDarkenerColor = _backgroundDarkenerColor;
@synthesize inFrontReferenceView = _inFrontReferenceView;
@synthesize popoverVisible = _popoverVisible;

-(void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willPresentNewPopover:) name:@"FPNewPopoverPresented" object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self
                                              selector:@selector(keyboardWillHide:)
                                                  name:UIKeyboardWillHideNotification
                                                object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self
                                              selector:@selector(keyboardShown:)
                                                  name:UIKeyboardDidShowNotification
                                                object:nil];
}

-(void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_viewController removeObserver:self forKeyPath:@"title"];
    [_viewController removeObserver:self forKeyPath:@"contentSizeForViewInPopover"];
}


-(void)dealloc
{
    [self removeObservers];
    self.delegate = nil;
     inFrontViewsParentView = nil;
}


-(id)initWithViewController:(UIViewController*)viewController {
    self = [super init];
    if(self) {
        _backgroundDarkenerColor = nil;
        self.arrowDirection = FPPopoverArrowDirectionAny;
        self.view.userInteractionEnabled = YES;
        _touchView = [[FPTouchView alloc] initWithFrame:self.view.bounds];
        _touchView.backgroundColor = [UIColor clearColor];
        _touchView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _touchView.clipsToBounds = NO;
        [self.view addSubview:_touchView];
        self.closesOnTapOff = YES;
        self.closesOnTapOn = NO;
        self.contentSize = viewController.contentSizeForViewInPopover;
        contentSizeWithoutKeyboard = self.contentSize;
        keyboardVisible = NO;

        _contentView = [[FPPopoverView alloc] initWithFrame:CGRectMake(0, 0, 
                                              self.contentSize.width, self.contentSize.height)];
        
        _viewController = viewController;
        
        [_touchView addSubview:_contentView];

        [_contentView setContentView:_viewController.view];
        [self updateAccessories];
        
        if ([_viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController*)_viewController;
            navigationController.delegate = self;
        }
        
        _viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.view.clipsToBounds = NO;

        _touchView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _touchView.clipsToBounds = NO;
        
        //setting contentview
        _contentView.title = _viewController.title;
        _contentView.clipsToBounds = NO;
        
        [_viewController addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
        [_viewController addObserver:self forKeyPath:@"contentSizeForViewInPopover" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)updateAccessories {
    UIViewController<FPPopoverAccessoriesProtocol> *accessoriesViewController = nil;
    if ([_viewController conformsToProtocol:@protocol(FPPopoverAccessoriesProtocol)]) {
        accessoriesViewController = (UIViewController<FPPopoverAccessoriesProtocol> *)_viewController;
    }

    if (accessoriesViewController) {
        if ([accessoriesViewController respondsToSelector:@selector(leftTopBarButton)]) {
            [_contentView setLeftButton:[accessoriesViewController leftTopBarButton]];
        }
        if ([accessoriesViewController respondsToSelector:@selector(rightTopBarButton)]) {
            [_contentView setRightButton:[accessoriesViewController rightTopBarButton]];
        }
        if ([accessoriesViewController respondsToSelector:@selector(bottomBarButtons)]) {
            [_contentView setBottomBarButtons:[accessoriesViewController bottomBarButtons]];
        }
        if ([accessoriesViewController respondsToSelector:@selector(centreTopView)]) {
            [_contentView setTopCentreView:[accessoriesViewController centreTopView]];
        }
    }
}

- (void)enableAccessoryInteraction:(BOOL)enable {
    UIViewController<FPPopoverAccessoriesProtocol> *accessoriesViewController = nil;
    if ([_viewController conformsToProtocol:@protocol(FPPopoverAccessoriesProtocol)]) {
        accessoriesViewController = (UIViewController<FPPopoverAccessoriesProtocol> *)_viewController;
    }
    
    if (accessoriesViewController) {
        if ([accessoriesViewController respondsToSelector:@selector(leftTopBarButton)]) {
            [accessoriesViewController leftTopBarButton].userInteractionEnabled = enable;
        }
        if ([accessoriesViewController respondsToSelector:@selector(rightTopBarButton)]) {
            [accessoriesViewController rightTopBarButton].userInteractionEnabled = enable;
        }
        if ([accessoriesViewController respondsToSelector:@selector(bottomBarButtons)]) {
            for (UIButton *button in [accessoriesViewController bottomBarButtons]) {
                button.userInteractionEnabled = enable;
            }
        }
        if ([accessoriesViewController respondsToSelector:@selector(centreTopView)]) {
            [accessoriesViewController centreTopView].userInteractionEnabled = enable;
        }
    }
}

-(void)setTint:(FPPopoverTint)tint
{
    _contentView.tint = tint;
    [_contentView setNeedsDisplay];
}

- (void)setStyle:(FPPopoverStyle*)style {
    _contentView.style = style;
    [_contentView setNeedsDisplay];
}

- (void)setClosesOnTapOff:(BOOL)closesOnTapOff {
    __weak FPPopoverController* weakSelf = self;
    if (closesOnTapOff) {
        [_touchView setTouchedOutsideBlock:^{
            if (weakSelf.delegate
                && [weakSelf.delegate respondsToSelector:@selector(popoverControllerShouldDismissPopover:)]) {
                if ([weakSelf.delegate popoverControllerShouldDismissPopover:weakSelf]) {
                    [weakSelf dismissPopoverAnimated:YES];
                }
            } else {
                [weakSelf dismissPopoverAnimated:YES];
            }
        }];
    } else {
        if (_contentView.style.hasTapOffNoCloseAnimation) {
            [_touchView setTouchedOutsideBlock:[_contentView touchedOutsideBlock]];
        } else {
            [_touchView setTouchedOutsideBlock:nil];
        }
    }
}

- (void)setClosesOnTapOn:(BOOL)closesOnTapOn {
    __weak FPPopoverController* weakSelf = self;
    if (closesOnTapOn) {
        [_touchView setTouchedInsideBlock:^{
            [weakSelf dismissPopoverAnimated:YES];
        }];
    } else {
        [_touchView setTouchedInsideBlock:nil];
    }
}

-(FPPopoverTint)tint
{
    return _contentView.tint;
}

- (void)setPopoverContentSize:(CGSize)popoverContentSize {
    if (!keyboardVisible) {
        contentSizeWithoutKeyboard = popoverContentSize;
    }
    CGSize nonContentSize = [self nonContentSize];
    popoverContentSize.width += nonContentSize.width;
    popoverContentSize.height += nonContentSize.height;
    self.contentSize = popoverContentSize;
    CGRect rect = _contentView.frame;
    rect.size = popoverContentSize;
    _contentView.frame = rect;// CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    [self setupView];
}

- (UIViewController *)contentViewController {
    return _viewController;
}

#pragma mark - View lifecycle

-(void)setupView
{
    self.view.frame = CGRectMake(0, 0, [self parentWidth], [self parentHeight]);
    _touchView.frame = self.view.bounds;
    
    //view position, size and best arrow direction
    [self bestArrowDirectionAndFrameFromView:_fromView];

    [_contentView setNeedsDisplay];
    [_touchView setNeedsDisplay];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initialize and load the content view
    [_contentView setArrowDirection:FPPopoverArrowDirectionUp];
    [_contentView setContentView:_viewController.view];

    [self setupView];
    [self addObservers];
}

- (void)viewWillAppear:(BOOL)animated {
    [_viewController viewWillAppear:animated];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    _popoverVisible = YES;
    [_viewController viewDidAppear:animated];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_viewController viewWillDisappear:animated];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    _popoverVisible = NO;
    [_viewController viewDidDisappear:animated];
    [super viewDidDisappear:animated];
}
#pragma mark Orientation

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


#pragma mark presenting

-(CGFloat)parentWidth
{
    return _parentView.bounds.size.width;
}

-(CGFloat)parentHeight
{
    return _parentView.bounds.size.height;
}

- (UIView*)containerViewFromWindow:(UIWindow *)window {
    for (UIView *view in window.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UILayoutContainerView")]) {
            return view;
        }
    }
    return nil;
}

-(void)presentPopoverFromPoint:(CGPoint)fromPoint
{
    self.origin = fromPoint;
    _contentView.relativeOrigin = [_parentView convertPoint:fromPoint toView:_contentView];

    [self.view removeFromSuperview];
    NSArray *windows = [UIApplication sharedApplication].windows;
    if(windows.count > 0)
    {
        _parentView = nil;
        _window = windows[0];
        //keep the first subview
        if (_window.subviews.count > 0)
        {
            _parentView = [self containerViewFromWindow:_window];
            self.view.frame = CGRectMake(0, 0, [self parentWidth], [self parentHeight]);
            [self createInFrontView];
            [self setupBackgroundDarkener];
            [_parentView addSubview:self.view];
            [self.view bringSubviewToFront:_touchView];
            [self.view bringSubviewToFront:_inFrontView];
        }
    } else {
        [self dismissPopoverAnimated:NO];
    }
    
    [self viewWillAppear:NO];
    [self setupView];
    _touchView.alpha = 0.0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FPNewPopoverPresented" object:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        _touchView.alpha = 1.0;
    }
     completion:^(BOOL finished) {
         if (_delegate && [_delegate respondsToSelector:@selector(popoverControllerDidDisplayPopover:)]) {
             [_delegate popoverControllerDidDisplayPopover:self];
         }
         [self viewDidAppear:NO];
    }];
}

- (UIImage *)imageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)createInFrontView {
    if (_inFrontReferenceView && _inFrontReferenceView.superview != self.view) {
        UIImage *imageOfView = [self imageFromView:_inFrontReferenceView];
        UIImageView *displayInFrontView = [[UIImageView alloc] initWithImage:imageOfView];
        inFrontViewsParentView = _inFrontReferenceView.superview;
        inFrontViewsFrame = _inFrontReferenceView.frame;
        CGRect frame = [_parentView convertRect:inFrontViewsFrame fromView:inFrontViewsParentView];
        displayInFrontView.frame = frame;
        [self.view addSubview:displayInFrontView];
        self.inFrontView = displayInFrontView;
    }
}

- (void)destroyInFrontView {
    [self.inFrontView removeFromSuperview];
    self.inFrontView = nil;
}

- (void)setupBackgroundDarkener {
    if (_backgroundDarkenerColor && _backgroundDarkenerColor.CGColor && _parentView) {
        CGFloat alpha = CGColorGetAlpha(_backgroundDarkenerColor.CGColor);
        if (alpha > 0.003f) {
            if (backgroundDarkener) {
                [backgroundDarkener removeFromSuperview];
            }
            CGRect darkenerFrame = _parentView.frame;
            UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
            if (UIInterfaceOrientationIsLandscape(orientation)) {
                darkenerFrame.size = CGSizeMake(darkenerFrame.size.height, darkenerFrame.size.width);
            }
            darkenerFrame.origin = CGPointZero;
            backgroundDarkener = [[UIView alloc] initWithFrame:darkenerFrame];
            backgroundDarkener.backgroundColor = _backgroundDarkenerColor;
            backgroundDarkener.alpha = 0.0f;
            [self.view addSubview:backgroundDarkener];
            [UIView animateWithDuration:0.2 animations:^{
                backgroundDarkener.alpha = 1.0;
            }];
        }
    }
}

-(CGPoint)originFromView:(UIView*)fromView
{
    CGPoint p;
    if([_contentView arrowDirection] == FPPopoverArrowDirectionUp)
    {
        p.x = fromView.frame.origin.x + fromView.frame.size.width/2.0;
        p.y = fromView.frame.origin.y + fromView.frame.size.height;
    }
    else if([_contentView arrowDirection] == FPPopoverArrowDirectionDown)
    {
        p.x = fromView.frame.origin.x + fromView.frame.size.width/2.0;
        p.y = fromView.frame.origin.y;        
    }
    else if([_contentView arrowDirection] == FPPopoverArrowDirectionLeft)
    {
        p.x = fromView.frame.origin.x + fromView.frame.size.width;
        p.y = fromView.frame.origin.y + fromView.frame.size.height/2.0;
    }
    else if([_contentView arrowDirection] == FPPopoverArrowDirectionRight)
    {
        p.x = fromView.frame.origin.x;
        p.y = fromView.frame.origin.y + fromView.frame.size.height/2.0;
    }
    else
    {
        p.x = fromView.frame.origin.x;
        p.y = fromView.frame.origin.y;
    }

    return p;
}

-(void)presentPopoverFromView:(UIView*)fromView
{
     _fromView = fromView;
    [self presentPopoverFromPoint:[self originFromView:_fromView]];
}

-(void)dismissPopover
{
    [self viewWillDisappear:NO];
    [self.view removeFromSuperview];
    [backgroundDarkener removeFromSuperview];
    [self destroyInFrontView];
    if([self.delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)])
    {
        [self.delegate popoverControllerDidDismissPopover:self];
    }
    self.delegate = nil;
    self.inFrontReferenceView = nil;
     inFrontViewsParentView = nil;
     backgroundDarkener = nil;
    [_touchView setTouchedOutsideBlock:nil];
    [_touchView setTouchedInsideBlock:nil];
     _window=nil;
     _parentView=nil;
    [self viewDidDisappear:NO];
}

-(void)dismissPopoverAnimated:(BOOL)animated {
    [self dismissPopoverAnimated:animated completion:NULL];
}

-(void)dismissPopoverAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    if (_delegate
        && [_delegate respondsToSelector:@selector(popoverControllerWillDismissPopover:animated:)]
        && [_delegate popoverControllerWillDismissPopover:self animated:animated] == NO) {
        return;
    }
    
    if(animated)
    {
        if (dismissalAnimationInProgress) {
            return;
        }
        dismissalAnimationInProgress = YES;
        [UIView animateWithDuration:0.2 animations:^{
            _touchView.alpha = 0.0;
            backgroundDarkener.alpha = 0.0f;
        } completion:^(BOOL finished) {
            dismissalAnimationInProgress = NO;
            [self dismissPopover];
            if (completion != NULL) {
                completion();
            }
        }];
    }
    else
    {
        [self dismissPopover];
        if (completion != NULL) {
            completion();
        }
    }
    
}

-(void)setOrigin:(CGPoint)origin
{
    _origin = origin;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self updateAccessories];
    [self enableAccessoryInteraction:NO];
    self.title = viewController.title;
    _contentView.title = viewController.title;
    [self setPopoverContentSize:viewController.contentSizeForViewInPopover];
    [_contentView setNeedsDisplay];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self enableAccessoryInteraction:YES];
}

#pragma mark observing

-(void)willPresentNewPopover:(NSNotification*)notification
{
    if(notification.object != self)
    {
        if([self.delegate respondsToSelector:@selector(presentedNewPopoverController:shouldDismissVisiblePopover:)])
        {
            [self.delegate presentedNewPopoverController:notification.object
                             shouldDismissVisiblePopover:self];
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == _viewController && [keyPath isEqualToString:@"title"]) {
        _contentView.title = _viewController.title;
        [_contentView setNeedsDisplay];
    } else if (object == _viewController && [keyPath isEqualToString:@"contentSizeForViewInPopover"]) {
        id newSizeValue = change[NSKeyValueChangeNewKey];
        CGSize newSize;
        
        [newSizeValue getValue:&newSize];
        [self setPopoverContentSize:newSize];
        [_contentView setNeedsDisplay];
    }
}

#pragma mark Notification handlers

- (void)keyboardShown:(NSNotification *)note {
    if (self.view.window == nil ||
        !_popoverVisible) {
        return;
    }
    keyboardVisible = YES;
    CGRect keyboardRect = [self keyboardFrameInThisWindowFromNotification:note];
    
    if (CGRectIntersectsRect(_contentView.frame, keyboardRect)) {
        [self shrinkToAccomodateKeyboard:keyboardRect];
    }
}

- (void)keyboardWillHide:(NSNotification *)note {
    if (self.view.window == nil ||
        !_popoverVisible) {
        return;
    }
    [self setContentSizeMaintainingOrigin:contentSizeWithoutKeyboard];
    keyboardVisible = NO;
}

- (CGRect)keyboardFrameInThisWindowFromNotification:(NSNotification *)note {
    NSDictionary *keyboardInfo = note.userInfo;
    NSValue *endRectValue = keyboardInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect;
    
    [endRectValue getValue:(void *)&keyboardRect];
    
    return [self.view.window convertRect:keyboardRect toView:self.view];
}

- (void)shrinkToAccomodateKeyboard:(CGRect)keyboardRect {
    CGRect intersection = CGRectIntersection(_contentView.frame, keyboardRect);
    CGSize newSize = _contentView.frame.size;
    CGSize nonContentSize = [self nonContentSize];
    
    newSize.width -= nonContentSize.width;
    newSize.height -= nonContentSize.height;
    newSize.height -= intersection.size.height;
    [self setContentSizeMaintainingOrigin:newSize];
}

- (CGSize)nonContentSize {
    CGSize size = CGSizeZero;
    
    if (FPPopoverArrowDirectionIsVertical(_contentView.arrowDirection)) {
        size.width += _contentView.style.borderWidth * 2.0f;
        size.height += _contentView.style.arrowHeight + _contentView.style.topBarHeight + _contentView.style.bottomBarHeight;
    } else {
        size.width += _contentView.style.arrowHeight + _contentView.style.borderWidth * 2.0f;
        size.height += _contentView.style.topBarHeight + _contentView.style.bottomBarHeight;
    }
    size.width += _contentView.style.contentFrameInset.width * 2.0f;
    size.height += _contentView.style.contentFrameInset.height * 2.0f;

    return size;
}

- (void)setContentSizeMaintainingOrigin:(CGSize)newContentSize {
    if ([_viewController isKindOfClass:[UINavigationController class]]
        && [(UINavigationController*)_viewController topViewController]) {
        [(UINavigationController*)_viewController topViewController].contentSizeForViewInPopover = newContentSize;
    }
    maintainOrigin = YES;
    originToMaintain = _contentView.frame.origin;
    _viewController.contentSizeForViewInPopover = newContentSize;
    maintainOrigin = NO;
}

#pragma mark Space management
/* This methods helps the controller to found a proper way to display the view.
 * If the "from point" will be on the left, the arrow will be on the left and the 
 * view will be move on the right of the from point.
 *
 * Consider only x direction
 *
 *  |--lm--|-----s-----|--rm--|
 *
 * s is the frame of our view (s < screen width). 
 * if our origin point is in lm or rm we move s
 * if the origin point is in s we move the arrow
 */
-(CGRect)bestViewFrameForFromPoint:(CGPoint)point
{
    //content view size
    CGRect r;
    r.size = self.contentSize;
    r.size.width += 20;
    r.size.height += 50;
    
    //size limits
    CGFloat w = MIN(r.size.width, [self parentWidth]);
    CGFloat h = MIN(r.size.height,[self parentHeight]);
    
    r.size.width = (w == [self parentWidth]) ? [self parentWidth]-50 : w;
    r.size.height = (h == [self parentHeight]) ? [self parentHeight]-30 : h;
    
    CGFloat r_w = r.size.width;
    CGFloat r_h = r.size.height;
    
    //lm + rm
    CGFloat wm = [self parentWidth] - r_w;
    CGFloat wm_l = wm/2.0;
    CGFloat ws = r_w;
    CGFloat rm_x = wm_l + ws;
    
    CGFloat hm = [self parentHeight] - r_h;
    CGFloat hm_t = hm/2.0; //top
    CGFloat hs = r_h;
    CGFloat hm_b = hm_t + hs; //bottom
    
    if(wm > 0)
    {
        //s < lm + rm
        //our content size is smaller then width
        
        //15px are the number of point from the border to the arrow when the
        //arrow is totally at left
        //I have considered a standard border of 2px

        if(point.x+15 <= wm_l)
        {
            //move the popup to the left, with the left side near the origin point
            r.origin.x = point.x-15;
        }
        else if(point.x+15 >= rm_x)
        {
            //move the popup to the right, with the right side near the origin point
            r.origin.x = point.x - ws + 22;
        }
        
        else
        {
            //the point is in the "s" zone and then I will move only the arrow
            //put in the x center the popup
            r.origin.x = wm_l;
        }
    }
    
    
    if(hm > 0)
    {
        //the point is on the top
        //let's move up the view
        if(point.y <= hm_t)
        {
            r.origin.y = point.y;            
        }
        //the point is on the bottom, 
        //let's move down the view
        else if(point.y > hm_b)
        {
            r.origin.y = point.y - hs;
        }
        
        else
        {
            //we need to resize the content
            r.origin.y = point.y;
            r.size.height = MIN(self.contentSize.height,[self parentHeight] - point.y - 10); //resizing
        }
    }
    
     return r;
}

+ (FPPopoverArrowDirection)bestVerticalArrowDirectionWithSpaceAbove:(CGFloat)spaceAbove
                                                         spaceBelow:(CGFloat)spaceBelow
{
    if (spaceAbove >= spaceBelow) {
        return FPPopoverArrowDirectionDown;
    } else {
        return FPPopoverArrowDirectionUp;
    }
}

+ (FPPopoverArrowDirection)bestHorizontalArrowDirectionWithSpaceOnLeft:(CGFloat)spaceOnLeft
                                                          spaceOnRight:(CGFloat)spaceOnRight
{
    if (spaceOnLeft >= spaceOnRight) {
        return FPPopoverArrowDirectionRight;
    } else {
        return FPPopoverArrowDirectionLeft;
    }
}

+ (FPPopoverArrowDirection)bestArrowDirectionWithHint:(FPPopoverArrowDirection)hint
                                           spaceAbove:(CGFloat)spaceAbove
                                           spaceBelow:(CGFloat)spaceBelow
                                          spaceOnLeft:(CGFloat)spaceOnLeft
                                         spaceOnRight:(CGFloat)spaceOnRight
{
    switch (hint) {
        case FPPopoverArrowDirectionUp:
        case FPPopoverArrowDirectionDown:
        case FPPopoverArrowDirectionLeft:
        case FPPopoverArrowDirectionRight:
            return hint;
        case FPPopoverArrowDirectionVertical:
            return [self bestVerticalArrowDirectionWithSpaceAbove:spaceAbove spaceBelow:spaceBelow];
        case FPPopoverArrowDirectionHorizontal:
            return [self bestHorizontalArrowDirectionWithSpaceOnLeft:spaceOnLeft spaceOnRight:spaceOnRight];
        case FPPopoverArrowDirectionAny:
        default:
            if (MAX(spaceAbove, spaceBelow) >= MAX(spaceOnLeft, spaceOnRight)) {
                return [self bestVerticalArrowDirectionWithSpaceAbove:spaceAbove spaceBelow:spaceBelow];
            } else {
                return [self bestHorizontalArrowDirectionWithSpaceOnLeft:spaceOnLeft spaceOnRight:spaceOnRight];
            }
    }
}

+ (CGPoint)popoverOriginForDirection:(FPPopoverArrowDirection)direction
                              origin:(CGPoint)origin
                            viewSize:(CGSize)viewSize
                         contentSize:(CGSize)contentSize
{
    CGPoint result;
    
    switch (direction) {
        case FPPopoverArrowDirectionDown:
            //on the top and arrow down
            result.x = origin.x + viewSize.width/2.0 - contentSize.width/2.0;
            result.y = origin.y - contentSize.height;
            break;
            
        case FPPopoverArrowDirectionUp:
            //on the bottom and arrow up
            result.x = origin.x + viewSize.width/2.0 - contentSize.width/2.0;
            result.y = origin.y + viewSize.height;
            break;
            
        case FPPopoverArrowDirectionRight:
            //on the left and arrow right
            result.x = origin.x - contentSize.width;
            result.y = origin.y + viewSize.height/2.0 - contentSize.height/2.0;
            break;
            
        case FPPopoverArrowDirectionLeft:
        default:
            //on the right then arrow left
            result.x = origin.x + viewSize.width;
            result.y = origin.y + viewSize.height/2.0 - contentSize.height/2.0;
    }
    
    return result;
}

-(CGRect)bestArrowDirectionAndFrameFromView:(UIView*)v
{
    const CGPoint origin = [v.superview convertPoint:v.frame.origin toView:self.view];
    
    const CGFloat spaceAbove = origin.y; //available vertical space on top of the view
    const CGFloat spaceBelow = [self parentHeight] -  (origin.y + v.frame.size.height); //on the bottom
    const CGFloat spaceOnLeft = origin.x; //on the left
    const CGFloat spaceOnRight = [self parentWidth] - (origin.x + v.frame.size.width); //on the right
    
    CGRect result;
    result.size = self.contentSize;

    const FPPopoverArrowDirection bestDirection = [FPPopoverController bestArrowDirectionWithHint:self.arrowDirection
                                                                                       spaceAbove:spaceAbove
                                                                                       spaceBelow:spaceBelow
                                                                                      spaceOnLeft:spaceOnLeft
                                                                                     spaceOnRight:spaceOnRight];
    
    result.origin = [FPPopoverController popoverOriginForDirection:bestDirection
                                                            origin:origin
                                                          viewSize:v.frame.size
                                                       contentSize:result.size];

    if (FPPopoverArrowDirectionIsHorizontal(bestDirection)) {
        if(CGRectGetMaxY(result) > [self parentHeight] && result.origin.y > 0)
        {
            result.origin.y = [self parentHeight] - result.size.height;
        }
    }
    
    //need to moved left ? 
    if(CGRectGetMaxX(result) > [self parentWidth])
    {
        result.origin.x = [self parentWidth] - result.size.width;
    }
    
    //need to moved right ?
    else if(result.origin.x < 0)
    {
        result.origin.x = 0;
    }
    
    if (maintainOrigin) {
        result.origin = originToMaintain;
    }
    
    //need to move up?
    if(result.origin.y < 0)
    {
        result.origin.y = 0;
    }
    
    //need to be resized horizontally ?
    if(CGRectGetMaxX(result) > [self parentWidth])
    {
        result.size.width = [self parentWidth] - result.origin.x;
    }
    
    //need to be resized vertically ?
    if(CGRectGetMaxY(result) > [self parentHeight])
    {
        result.size.height = [self parentHeight] - result.origin.y;
    }
    
    if([[UIApplication sharedApplication] isStatusBarHidden] == NO)
    {
        if(result.origin.y < 20) {
            result.origin.y += 20;
        }
    }

    _contentView.arrowDirection = bestDirection;
    _contentView.frame = CGRectIntegral(result);

    self.origin = CGPointMake(origin.x + v.frame.size.width/2.0, origin.y + v.frame.size.height/2.0);
    _contentView.relativeOrigin = [_parentView convertPoint:self.origin toView:_contentView];

    return result;
}




@end
