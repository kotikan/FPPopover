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
    BOOL dismissalAnimationInProgress;
}

@synthesize delegate = _delegate;
@synthesize contentSize = _contentSize;
@synthesize origin = _origin;
@synthesize arrowDirection = _arrowDirection;
@synthesize tint = _tint;
@synthesize backgroundDarkenerColor = _backgroundDarkenerColor;
@synthesize inFrontView = _inFrontView;
@synthesize popoverVisible = _popoverVisible;

-(void)addObservers
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];   
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self 
     selector:@selector(deviceOrientationDidChange:) 
     name:@"UIDeviceOrientationDidChangeNotification" 
     object:nil]; 
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willPresentNewPopover:) name:@"FPNewPopoverPresented" object:nil];
    
    _deviceOrientation = [UIDevice currentDevice].orientation;
    
}

-(void)removeObservers
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_viewController removeObserver:self forKeyPath:@"title"];
    [_viewController removeObserver:self forKeyPath:@"contentSizeForViewInPopover"];
}


-(void)dealloc
{
    [self removeObservers];
    [_touchView release];
    [_viewController release];
    [_contentView release];
    [_window release];
    [_parentView release];
    [backgroundDarkener release];
    self.delegate = nil;
    [inFrontViewsParentView release]; inFrontViewsParentView = nil;
    self.inFrontView = nil;
    [super dealloc];
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

        _contentView = [[FPPopoverView alloc] initWithFrame:CGRectMake(0, 0, 
                                              self.contentSize.width, self.contentSize.height)];
        
        _viewController = [viewController retain];
        
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
    if (closesOnTapOff) {
        [_touchView setTouchedOutsideBlock:^{
            [self dismissPopoverAnimated:YES];
        }];
    } else {
        [_touchView setTouchedOutsideBlock:nil];
    }
}

- (void)setClosesOnTapOn:(BOOL)closesOnTapOn {
    if (closesOnTapOn) {
        [_touchView setTouchedInsideBlock:^{
            [self dismissPopoverAnimated:YES];
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
    if (FPPopoverArrowDirectionIsVertical(_contentView.arrowDirection)) {
        popoverContentSize.width += _contentView.style.borderWidth * 2.0f;
        popoverContentSize.height += _contentView.style.arrowHeight + _contentView.style.topBarHeight + _contentView.style.bottomBarHeight;
    } else {
        popoverContentSize.width += _contentView.style.arrowHeight + _contentView.style.borderWidth * 2.0f;
        popoverContentSize.height += _contentView.style.topBarHeight + _contentView.style.bottomBarHeight;
    }
    popoverContentSize.width += _contentView.style.contentFrameInset.width * 2.0f;
    popoverContentSize.height += _contentView.style.contentFrameInset.height * 2.0f;
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
    return UIDeviceOrientationIsPortrait(_deviceOrientation) ? _parentView.frame.size.width : _parentView.frame.size.height;
}
-(CGFloat)parentHeight
{
    return _parentView.bounds.size.height;
    return UIDeviceOrientationIsPortrait(_deviceOrientation) ? _parentView.frame.size.height : _parentView.frame.size.width;
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
        [_window release];
        [_parentView release];
        _parentView = nil;
        _window = [[windows objectAtIndex:0] retain];
        //keep the first subview
        if (_window.subviews.count > 0)
        {
            [_parentView release]; 
            _parentView = [[self containerViewFromWindow:_window] retain];
            self.view.frame = CGRectMake(0, 0, [self parentWidth], [self parentHeight]);
            [self setupBackgroundDarkener];
            [self setupInFrontView];
            [_parentView addSubview:self.view];
            [self.view bringSubviewToFront:_touchView];
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

- (void)setupInFrontView {
    if (backgroundDarkener && _inFrontView) {
        inFrontViewsParentView = [_inFrontView.superview retain];
        inFrontViewsFrame = _inFrontView.frame;
        CGRect newRect = [_parentView convertRect:inFrontViewsFrame fromView:inFrontViewsParentView];
        [_inFrontView removeFromSuperview];
        _inFrontView.frame = newRect;
        [self.view addSubview:_inFrontView];
    }
}

- (void)revertInFrontView {
    if (_inFrontView && inFrontViewsParentView) {
        [_inFrontView removeFromSuperview];
        _inFrontView.frame = inFrontViewsFrame;
        if (inFrontViewsParentView.superview) {
            [inFrontViewsParentView addSubview:_inFrontView];
        }
    }
}

- (void)setupBackgroundDarkener {
    if (_backgroundDarkenerColor && _backgroundDarkenerColor.CGColor && _parentView) {
        CGFloat alpha = CGColorGetAlpha(_backgroundDarkenerColor.CGColor);
        if (alpha > 0.003f) {
            if (backgroundDarkener) {
                [backgroundDarkener removeFromSuperview];
                [backgroundDarkener release];
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

    return p;
}

-(void)presentPopoverFromView:(UIView*)fromView
{
    [_fromView release]; _fromView = [fromView retain];
    [self presentPopoverFromPoint:[self originFromView:_fromView]];
}

-(void)dismissPopover
{
    [self viewWillDisappear:NO];
    [self.view removeFromSuperview];
    [backgroundDarkener removeFromSuperview];
    [self revertInFrontView];
    if([self.delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)])
    {
        [self.delegate popoverControllerDidDismissPopover:self];
    }
    self.inFrontView = nil;
    [inFrontViewsParentView release]; inFrontViewsParentView = nil;
    [backgroundDarkener release]; backgroundDarkener = nil;
    [_touchView setTouchedOutsideBlock:nil];
    [_touchView setTouchedInsideBlock:nil];
    [_window release]; _window=nil;
    [_parentView release]; _parentView=nil;
    [self viewDidDisappear:NO];
}

-(void)dismissPopoverAnimated:(BOOL)animated
{
    if (_delegate
        && [_delegate respondsToSelector:@selector(popoverControllerWillDismissPopover:)]
        && [_delegate popoverControllerWillDismissPopover:self] == NO) {
        DLog(@"Delegate %@ prevents popover from being dismissed", _delegate);
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
        }];
    }
    else
    {
        [self dismissPopover];
    }
         
}

-(void)setOrigin:(CGPoint)origin
{
    _origin = origin;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self updateAccessories];
    self.title = viewController.title;
    _contentView.title = viewController.title;
    [self setPopoverContentSize:viewController.contentSizeForViewInPopover];
    [_contentView setNeedsDisplay];
}

#pragma mark observing

-(void)deviceOrientationDidChange:(NSNotification*)notification
{
    _deviceOrientation = [UIDevice currentDevice].orientation;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self setupView]; 
    }];
}

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
        [self setPopoverContentSize:_viewController.contentSizeForViewInPopover];
        [_contentView setNeedsDisplay];
    }
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

-(CGRect)bestArrowDirectionAndFrameFromView:(UIView*)v
{
    CGPoint p = [v.superview convertPoint:v.frame.origin toView:self.view];
    
    CGFloat ht = p.y; //available vertical space on top of the view
    CGFloat hb = [self parentHeight] -  (p.y + v.frame.size.height); //on the bottom
    CGFloat wl = p.x; //on the left
    CGFloat wr = [self parentWidth] - (p.x + v.frame.size.width); //on the right
        
    CGFloat best_h = MAX(ht, hb); //much space down or up ?
    CGFloat best_w = MAX(wl, wr);
    
    CGRect r;
    r.size = self.contentSize;

    FPPopoverArrowDirection bestDirection;
    
    //if the user wants vertical arrow, check if the content will fit vertically 
    if(FPPopoverArrowDirectionIsVertical(self.arrowDirection) || 
       (self.arrowDirection == FPPopoverArrowDirectionAny && best_h >= best_w))
    {

        //ok, will be vertical
        if(ht == best_h || self.arrowDirection == FPPopoverArrowDirectionDown)
        {
            //on the top and arrow down
            bestDirection = FPPopoverArrowDirectionDown;
            
            r.origin.x = p.x + v.frame.size.width/2.0 - r.size.width/2.0;
            r.origin.y = p.y - r.size.height;
        }
        else
        {
            //on the bottom and arrow up
            bestDirection = FPPopoverArrowDirectionUp;

            r.origin.x = p.x + v.frame.size.width/2.0 - r.size.width/2.0;
            r.origin.y = p.y + v.frame.size.height;
        }
        

    }
    
    
    else 
    {
        //ok, will be horizontal 
        if(wl == best_w && self.arrowDirection != FPPopoverArrowDirectionLeft)
        {
            //on the left and arrow right
            bestDirection = FPPopoverArrowDirectionRight;

            r.origin.x = p.x - r.size.width;
            r.origin.y = p.y + v.frame.size.height/2.0 - r.size.height/2.0;

        }
        else
        {
            //on the right then arrow left
            bestDirection = FPPopoverArrowDirectionLeft;

            r.origin.x = p.x + v.frame.size.width;
            r.origin.y = p.y + v.frame.size.height/2.0 - r.size.height/2.0;
        }
        

    }
    
    
    
    //need to moved left ? 
    if(r.origin.x + r.size.width > [self parentWidth])
    {
        r.origin.x = [self parentWidth] - r.size.width;
    }
    
    //need to moved right ?
    else if(r.origin.x < 0)
    {
        r.origin.x = 0;
    }
    
    
    //need to move up?
    if(r.origin.y < 0)
    {
        CGFloat old_y = r.origin.y;
        r.origin.y = 0;
        r.size.height += old_y;
    }
    
    //need to be resized horizontally ?
    if(r.origin.x + r.size.width > [self parentWidth])
    {
        r.size.width = [self parentWidth] - r.origin.x;
    }
    
    //need to be resized vertically ?
    if(r.origin.y + r.size.height > [self parentHeight])
    {
        r.size.height = [self parentHeight] - r.origin.y;
    }
    
    
    if([[UIApplication sharedApplication] isStatusBarHidden] == NO)
    {
        if(r.origin.y <= 20) r.origin.y += 20;
    }

    _contentView.arrowDirection = bestDirection;
    _contentView.frame = CGRectIntegral(r);

    self.origin = CGPointMake(p.x + v.frame.size.width/2.0, p.y + v.frame.size.height/2.0);
    _contentView.relativeOrigin = [_parentView convertPoint:self.origin toView:_contentView];

    return r;
}




@end
