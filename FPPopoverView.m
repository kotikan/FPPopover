//
//  FPPopoverView.m
//
//  Created by Alvise Susmel on 1/4/12.
//  Copyright (c) 2012 Fifty Pixels Ltd. All rights reserved.
//
//  https://github.com/50pixels/FPPopover
//
// Updated by Jock Findlay
// https://github.com/kotikan/FPPopover

#import "FPPopoverView.h"
#import "FPPopoverStyle.h"
#import "FPPopoverBlackStyle.h"
#import "FPPopoverLightGrayStyle.h"
#import "FPPopoverGreenStyle.h"
#import "FPPopoverRedStyle.h"

#define TitleHorizontalPadding (2)
#define StylingAnimationDurationIn (0.3)
#define StylingAnimationDurationPause (0.3)
#define StylingAnimationDurationOut (0.3)

float fade( const float t ) { return t * t * t * (t * (t * 6 - 15) + 10); }

@interface FPPopoverView(Private)
-(void)setupViews;
@end


@implementation FPPopoverView {
    UIButton *leftButton;
    UIButton *rightButton;
    NSArray *bottomBarButtons;
    UIView *topCentreView;
    NSTimer *animationTimer;
    NSTimeInterval animationStartTime;
}

@synthesize title;
@synthesize relativeOrigin;
@synthesize tint = _tint;
@synthesize style = _style;

-(void)dealloc {
    self.title = nil;
    self.style = nil;
    [_contentView release];
    [_titleLabel release];
    [bottomBarButtons release];
    [leftButton release];
    [rightButton release];
    [animationTimer invalidate];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        //we need to set the background as clear to see the view below
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
        self.layer.shadowOpacity = 0.7;
        self.layer.shadowRadius = 5;
        self.layer.shadowOffset = CGSizeMake(-3, 3);

        //to get working the animations
        self.contentMode = UIViewContentModeRedraw;

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = UITextAlignmentCenter;

        [self addSubview:_titleLabel];
        
        self.tint = FPPopoverDefaultTint;
    }
    return self;
}

- (void)setTint:(FPPopoverTint)tint {
    switch (tint) {
        case FPPopoverLightGrayTint:
            self.style = [[[FPPopoverLightGrayStyle alloc] init] autorelease];
            break;
        case FPPopoverGreenTint:
            self.style = [[[FPPopoverGreenStyle alloc] init] autorelease];
            break;
        case FPPopoverRedTint:
            self.style = [[[FPPopoverRedStyle alloc] init] autorelease];
            break;
        case FPPopoverBlackTint:
        default:
            self.style = [[[FPPopoverBlackStyle alloc] init] autorelease];
            break;
    }
}

- (void)setStyle:(FPPopoverStyle *)style {
    if (_style) {
        [_style.frameView removeFromSuperview];
        [_style.overlayView removeFromSuperview];
    }
    [style retain];
    [_style release];
    _style = style;
    if (!_style) {
        return;
    }

    _titleLabel.textColor = _style.titleColor;
    _titleLabel.shadowColor = _style.titleShadowColor;
    _titleLabel.shadowOffset = _style.titleShadowOffset;
    _titleLabel.font = _style.titleFont;
    self.layer.shadowOpacity = _style.shadowOpacity;
    self.layer.shadowColor = _style.shadowColor.CGColor;
    self.layer.shadowRadius = _style.shadowRadius;
    if ([_style frameView]) {
        [self addSubview:[_style frameView]];
        if (_contentView) {
            [self bringSubviewToFront:_contentView];
        }
    }
    if ([_style overlayView]) {
        _style.overlayView.frame = _contentView.frame;
        [self addSubview:_style.overlayView];
        [self bringSubviewToFront:_style.overlayView];
    }
    if (_style.contentCornerRadius > 0.0f && _contentView) {
        [_contentView.layer setCornerRadius:_style.contentCornerRadius];
        [_contentView.layer setMasksToBounds:YES];
    }
    [self setupViews];
}

- (void)setTitle:(NSString *)newTitle {
    [newTitle retain];
    [title release];
    title = newTitle;
    [self updateTitleLabel];
}

#pragma mark setters

-(void)setArrowDirection:(FPPopoverArrowDirection)arrowDirection {
    _arrowDirection = arrowDirection;
    [self setNeedsDisplay];
}

-(FPPopoverArrowDirection)arrowDirection {
    return _arrowDirection;
}

-(void)setContentView:(UIView *)contentView {
    if(_contentView != contentView) {
        [_contentView removeFromSuperview];
        [_contentView release];
        _contentView = [contentView retain];
        if (_style.contentCornerRadius > 0.0f) {
            [_contentView.layer setCornerRadius:_style.contentCornerRadius];
            [_contentView.layer setMasksToBounds:YES];
        }
        [self addSubview:_contentView];
    }
    [self setupViews];
}

- (void)setLeftButton:(UIButton*)button {
    if (leftButton) {
        [leftButton removeFromSuperview];
    }
    [button retain];
    [leftButton release];
    leftButton = button;
    if (!button) {
        return;
    }
    [self addSubview:leftButton];
    [self updateLeftButtonFrame];
}

- (void)setRightButton:(UIButton*)button {
    if (rightButton) {
        [rightButton removeFromSuperview];
    }
    [button retain];
    [rightButton release];
    rightButton = button;
    if (!button) {
        return;
    }
    [self addSubview:rightButton];
    [self updateRightButtonFrame];
}

- (void)setTopCentreView:(UIView*)view {
    if (topCentreView) {
        [topCentreView removeFromSuperview];
    }
    [view retain];
    [topCentreView release];
    topCentreView = view;
    if (!topCentreView) {
        return;
    }
    [self addSubview:topCentreView];
    [self updateTopCentreViewFrame];
}

- (void)setBottomBarButtons:(NSArray *)buttons {
    if (bottomBarButtons) {
        for (UIButton *button in bottomBarButtons) {
            [button removeFromSuperview];
        }
    }
    [buttons retain];
    [bottomBarButtons release];
    bottomBarButtons = buttons;
    if (!buttons) {
        return;
    }
    for (UIButton *button in bottomBarButtons) {
        [self addSubview:button];
    }
    [self updateBottomBarButtonFrames];
}

- (void)updateBottomBarButtonFrames {
    if (!bottomBarButtons) {
        return;
    }
    CGRect outerRect = [self outerRectForBorderWidth:1.0f];
    CGFloat widthForButtons = outerRect.size.width - (_style.borderWidth * 2.0f);
    CGFloat buttonWidths = [self bottomBarButtonsWidth];
    NSUInteger gaps = bottomBarButtons.count - 1;
    UIButton *firstButton = [bottomBarButtons objectAtIndex:0];
    CGRect firstButtonFrame = firstButton.frame;
    CGFloat y = (outerRect.origin.y + outerRect.size.height) - (_style.borderWidth + firstButtonFrame.size.height);
    if (gaps <= 0) {
        firstButtonFrame.origin.x = outerRect.origin.x + _style.borderWidth + (widthForButtons - buttonWidths) * 0.5f;
        firstButtonFrame.origin.y = y;
        firstButton.frame = CGRectIntegral(firstButtonFrame);
    } else {
        CGFloat gapWidth = (widthForButtons - buttonWidths) / (CGFloat)gaps;
        CGFloat x = _style.borderWidth + outerRect.origin.x;

        for (UIButton *button in bottomBarButtons) {
            CGRect buttonFrame = button.frame;
            buttonFrame.origin.x = x;
            buttonFrame.origin.y = y;
            button.frame = CGRectIntegral(buttonFrame);

            x += buttonFrame.size.width + gapWidth;
        }
    }
}

- (CGFloat)bottomBarButtonsWidth {
    CGFloat width = 0.0f;
    for (UIButton *button in bottomBarButtons) {
        width += button.frame.size.width;
    }
    return width;
}

- (void)updateRightButtonFrame {
    if (!rightButton) {
        return;
    }
    CGRect outerRect = [self outerRectForBorderWidth:1.0f];
    CGRect rightButtonFrame = CGRectMake(outerRect.origin.x + outerRect.size.width - (rightButton.frame.size.width + _style.borderWidth),
                                         outerRect.origin.y + _style.borderWidth,
                                         rightButton.frame.size.width,
                                         rightButton.frame.size.height);
    
    rightButton.frame = CGRectIntegral(rightButtonFrame);
}

- (void)updateTopCentreViewFrame {
    if (!topCentreView) {
        return;
    }
    CGRect outerRect = [self outerRectForBorderWidth:1.0f];
    CGRect topCentreFrame = CGRectMake(outerRect.origin.x + outerRect.size.width * 0.5f - topCentreView.frame.size.width * 0.5f,
                                         outerRect.origin.y + _style.borderWidth,
                                         topCentreView.frame.size.width,
                                         topCentreView.frame.size.height);
    
    topCentreView.frame = CGRectIntegral(topCentreFrame);
}

- (void)updateLeftButtonFrame {
    if (!leftButton) {
        return;
    }
    CGRect outerRect = [self outerRectForBorderWidth:1.0f];
    CGRect leftButtonFrame = CGRectMake(outerRect.origin.x + _style.borderWidth,
                                        outerRect.origin.y + _style.borderWidth,
                                        leftButton.frame.size.width,
                                        leftButton.frame.size.height);
    
    leftButton.frame = CGRectIntegral(leftButtonFrame);
}

#pragma mark drawing

- (CGRect)outerRectForBorderWidth:(CGFloat)borderWidth {
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    CGFloat ah = _style.arrowHeight; //is the height of the triangle of the arrow
    CGFloat b = borderWidth;
    CGRect rect;
    if (_arrowDirection == FPPopoverArrowDirectionUp) {
        rect.size.width = w - 2*b;
        rect.size.height = h - ah - 2*b;
        rect.origin.x = b;
        rect.origin.y = ah + b;
    } else if (_arrowDirection == FPPopoverArrowDirectionDown) {
        rect.size.width = w - 2*b;
        rect.size.height = h - ah - 2*b;
        rect.origin.x = b;
        rect.origin.y = b;
    } else if (_arrowDirection == FPPopoverArrowDirectionRight) {
        rect.size.width = w - ah - 2*b;
        rect.size.height = h - 2*b;
        rect.origin.x = b;
        rect.origin.y = b;
    } else {
        //Assuming _arrowDirection == FPPopoverArrowDirectionLeft to suppress static analyzer warnings
        rect.size.width = w - ah - 2*b;
        rect.size.height = h - 2*b;
        rect.origin.x = ah + b;
        rect.origin.y = b;
    }
    return rect;
}

-(CGPathRef)newTopEdgePathWithBorderWidth:(CGFloat)borderWidth {
    CGFloat ah = _style.arrowHeight; //is the height of the triangle of the arrow
    CGFloat aw = _style.arrowBaseWidth/2.0; //is the 1/2 of the base of the arrow
    CGFloat radius = _style.cornerRadius;
    CGFloat b = borderWidth;
    CGRect rect = [self outerRectForBorderWidth:borderWidth];

    //the arrow will be near the origin
    CGFloat ax = self.relativeOrigin.x - aw; //the start of the arrow when UP or DOWN
    if (ax < radius + b) {
        ax = radius + b;
    } else if (ax > self.bounds.size.width - radius - (2*aw) - (2*b)) {
        ax = self.bounds.size.width - radius - (2*aw) - (2*b);
    }

    //ROUNDED RECT
    // arrow UP
    CGRect innerRect = CGRectInset(rect, radius, radius);
    CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
    CGFloat inside_left = innerRect.origin.x;
    CGFloat inside_top = innerRect.origin.y;
    CGFloat outside_top = rect.origin.y;
    CGMutablePathRef path = CGPathCreateMutable();
    UIBezierPath *quarterCircle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(inside_left - ([_style topEdgeHighlightWidth]/2), inside_top)
                                                                 radius:radius
                                                             startAngle:7.0f * M_PI / 6.0f
                                                               endAngle:3.0f * M_PI / 2.0f
                                                              clockwise:YES];
    CGPathAddPath(path, NULL, quarterCircle.CGPath);
    if(_arrowDirection == FPPopoverArrowDirectionUp) {
        CGPathAddLineToPoint(path, NULL, ax, ah+b);
        CGPathAddLineToPoint(path, NULL, ax+aw, b);
        CGPathAddLineToPoint(path, NULL, ax+2*aw, ah+b);
    }
    CGPathAddLineToPoint(path, NULL, inside_right, outside_top);
    quarterCircle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(inside_right + ([_style topEdgeHighlightWidth]/2), inside_top)
                                                   radius:radius
                                               startAngle:3.0f * M_PI / 2.0f
                                                 endAngle:11.0f * M_PI / 6.0f
                                                clockwise:YES];
    CGPathAddPath(path, NULL, quarterCircle.CGPath);

    return path;
}

//the content with the arrow
-(CGPathRef)newContentPathWithBorderWidth:(CGFloat)borderWidth {
    CGFloat ah = _style.arrowHeight; //is the height of the triangle of the arrow
    CGFloat aw = _style.arrowBaseWidth/2.0; //is the 1/2 of the base of the arrow
    CGFloat radius = _style.cornerRadius;
    CGFloat b = borderWidth;
    CGRect rect = [self outerRectForBorderWidth:borderWidth];

    //the arrow will be near the origin
    CGFloat ax = self.relativeOrigin.x - aw; //the start of the arrow when UP or DOWN
    if (ax < radius + b) {
        ax = radius + b;
    } else if (ax > self.bounds.size.width - radius - (2*aw) - (2*b)) {
        ax = self.bounds.size.width - radius - (2*aw) - (2*b);
    }

    CGFloat ay = self.relativeOrigin.y - aw; //the start of the arrow when RIGHT or LEFT
    if (ay < radius + b) {
        ay = radius + b;
    } else if (ay > self.bounds.size.height - radius - (2*aw) - (2*b)) {
        ay = self.bounds.size.height - radius - (2*aw) - (2*b);
    }
    
    //ROUNDED RECT
    // arrow UP
    CGRect innerRect = CGRectInset(rect, radius, radius);
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;    
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;

    //drawing the border with arrow
    CGMutablePathRef path = CGPathCreateMutable();

    CGPathMoveToPoint(path, NULL, innerRect.origin.x, outside_top);
 
    if (_arrowDirection == FPPopoverArrowDirectionUp) {
        CGPathAddLineToPoint(path, NULL, ax, ah+b);
        CGPathAddLineToPoint(path, NULL, ax+aw, b);
        CGPathAddLineToPoint(path, NULL, ax+2*aw, ah+b);
    }
    CGPathAddLineToPoint(path, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(path, NULL, outside_right, outside_top, outside_right, inside_top, radius);
    if (_arrowDirection == FPPopoverArrowDirectionRight) {
        CGPathAddLineToPoint(path, NULL, outside_right, ay);
        CGPathAddLineToPoint(path, NULL, outside_right + ah+b, ay + aw);
        CGPathAddLineToPoint(path, NULL, outside_right, ay + 2*aw);
    }
	CGPathAddLineToPoint(path, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(path, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
    if (_arrowDirection == FPPopoverArrowDirectionDown) {
        CGPathAddLineToPoint(path, NULL, ax+2*aw, outside_bottom);
        CGPathAddLineToPoint(path, NULL, ax+aw, outside_bottom + ah);
        CGPathAddLineToPoint(path, NULL, ax, outside_bottom);
    }
	CGPathAddLineToPoint(path, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(path, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
    if (_arrowDirection == FPPopoverArrowDirectionLeft) {
        CGPathAddLineToPoint(path, NULL, outside_left, ay + 2*aw);
        CGPathAddLineToPoint(path, NULL, outside_left - ah-b, ay + aw);
        CGPathAddLineToPoint(path, NULL, outside_left, ay);
    }
	CGPathAddLineToPoint(path, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(path, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
    CGPathCloseSubpath(path);
    
    return path;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);

    CGPathRef contentPath = [self newContentPathWithBorderWidth:2.0f];
    CGContextAddPath(ctx, contentPath);
    CGContextClip(ctx);
    [self drawHeaderGradient:ctx];
    [self drawMain:ctx];
    if ([_style bottomBarGradientHeight] > 0.0f) {
        [self drawBottomBarGradient:ctx];
    }
    if ([_style outerBorderColor]) {
        [self drawOuterBorder:ctx withPath:contentPath];
    }
    CGPathRelease(contentPath);
    if ([_style topEdgeHighlightColor]) {
        [self drawTopEdgeHighlight:ctx];
    }
    if ([_style innerBorderColor]) {
        [self drawInnerBorder:ctx];
    }
    if ([_style outerContentFrameColor] && [_style innerContentFrameColor]) {
        [self drawContentFrame:ctx];
    }

    CGContextRestoreGState(ctx);
}

- (void)drawContentFrame:(CGContextRef)ctx {
    // 3D border of the content view
    CGRect cvRect = _contentView.frame;
    // inner line
    UIColor *color = [_style innerContentFrameColor];
    CGContextSetLineWidth(ctx, [_style innerContentFrameWidth]);
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextStrokeRect(ctx, cvRect);

    // outer line
    CGFloat maxLineWidth = MAX([_style innerContentFrameWidth], [_style outerContentFrameWidth]);
    cvRect.origin.x -= maxLineWidth; cvRect.origin.y -= maxLineWidth;
    cvRect.size.height += 2.0f * maxLineWidth; cvRect.size.width += 2.0f * maxLineWidth;
    color = [_style innerContentFrameColor];
    CGContextSetLineWidth(ctx, [_style outerContentFrameWidth]);
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextStrokeRect(ctx, cvRect);
}

- (void)drawInnerBorder:(CGContextRef)ctx {
    CGPathRef internalBorderPath = [self newContentPathWithBorderWidth:3.0];
    [self drawBorder:ctx withPath:internalBorderPath color:[_style innerBorderColor] andWidth:[_style innerBorderWidth]];
    CGPathRelease(internalBorderPath);
}

- (void)drawTopEdgeHighlight:(CGContextRef)ctx {
    CGPathRef topEdgePath = [self newTopEdgePathWithBorderWidth:2.0];
    [self drawBorder:ctx withPath:topEdgePath color:[_style topEdgeHighlightColor] andWidth:[_style topEdgeHighlightWidth]];
    CGPathRelease(topEdgePath);
}

- (void)drawOuterBorder:(CGContextRef)ctx withPath:(CGPathRef)path {
    [self drawBorder:ctx withPath:path color:[_style outerBorderColor] andWidth:[_style outerBorderWidth]];
}

- (void)drawBorder:(CGContextRef)ctx withPath:(CGPathRef)path color:(UIColor *)color andWidth:(CGFloat)width {
    CGContextBeginPath(ctx);
    CGContextAddPath(ctx, path);
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextSetLineWidth(ctx, width);
    CGContextSetLineCap(ctx,kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextStrokePath(ctx);
}

- (void)drawBottomBarGradient:(CGContextRef)ctx {
    CGFloat startY = self.bounds.size.height - [_style bottomBarGradientHeight];
    if (_arrowDirection == FPPopoverArrowDirectionDown) {
        startY -= [_style arrowHeight];
    }
    CGPoint start = CGPointMake(self.bounds.size.width/2.0, startY);
    CGPoint end = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height);
    CGGradientRef gradient;
    if (_arrowDirection == FPPopoverArrowDirectionDown) {
        gradient = [_style bottomBarGradientForBottomArrow];
    } else {
        gradient = [_style bottomBarGradientForNonBottomArrow];
    }
    CGContextDrawLinearGradient(ctx, gradient, start, end, 0);
}

- (void)drawMain:(CGContextRef)ctx {
    if ([_style borderGradient] == nil) {
        [self drawMainFill:ctx];
    } else {
        [self drawMainGradient:ctx];
    }
}

- (void)drawMainFill:(CGContextRef)ctx {
    UIColor *fillColor = [_style borderColor];
    CGFloat startY = [_style topBarGradientHeight];
    if (_arrowDirection == FPPopoverArrowDirectionUp) {
        startY += [_style arrowHeight];
    }
    CGFloat height = self.bounds.size.height - startY;

    CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
    if ([_style bottomBarGradientHeight] > 0.0f) {
        height -= [_style bottomBarGradientHeight];
        if (_arrowDirection == FPPopoverArrowDirectionDown) {
            height -= [_style arrowHeight];
        }
    }
    CGContextFillRect(ctx, CGRectMake(0, startY, self.bounds.size.width, height));
}

- (void)drawMainGradient:(CGContextRef)ctx {
    CGPoint start;
    
    if (_arrowDirection == FPPopoverArrowDirectionUp) {
        start = CGPointMake(self.bounds.size.width/2.0, [_style arrowHeight] + [_style topBarGradientHeight]);
    } else {
        start = CGPointMake(self.bounds.size.width/2.0, [_style topBarGradientHeight]);
    }

    CGPoint end;
    
    if (_arrowDirection == FPPopoverArrowDirectionDown) {
        end = CGPointMake(self.bounds.size.width/2.0,
                          self.bounds.size.height - ([_style bottomBarGradientHeight] + [_style arrowHeight]));
    } else {
        end = CGPointMake(self.bounds.size.width/2.0,
                          self.bounds.size.height - [_style bottomBarGradientHeight]);
    }
    CGContextDrawLinearGradient(ctx, [_style borderGradient], start, end, 0);
}

- (void)drawHeaderGradient:(CGContextRef)ctx {
    CGPoint start;
    CGPoint end;
    CGGradientRef gradient;

    if (_arrowDirection == FPPopoverArrowDirectionUp) {
        gradient = [_style topBarGradientForTopArrow];
    } else {
        gradient = [_style topBarGradientForNonTopArrow];
    }

    if (_arrowDirection == FPPopoverArrowDirectionUp) {
        start = CGPointMake(self.bounds.size.width/2.0, 0);
        end = CGPointMake(self.bounds.size.width/2.0, [_style arrowHeight] + [_style topBarGradientHeight]);
    } else {
        start = CGPointMake(self.bounds.size.width/2.0, 0);
        end = CGPointMake(self.bounds.size.width/2.0, [_style topBarGradientHeight]);
    }
    CGContextDrawLinearGradient(ctx, gradient, start, end, 0);
}

-(void)setupViews {
    //content position and size
    CGRect contentRect = _contentView.frame;
	
    if (_arrowDirection == FPPopoverArrowDirectionUp) {
        contentRect.origin = CGPointMake(_style.borderWidth, _style.arrowHeight + _style.topBarHeight);
        contentRect.size = CGSizeMake(self.bounds.size.width - 2.0f * _style.borderWidth,
                self.bounds.size.height - (_style.arrowHeight + _style.topBarHeight + _style.bottomBarHeight));
		if (self.title == nil) {
			contentRect.origin = CGPointMake(_style.borderWidth, _style.arrowHeight + _style.borderWidth);
			contentRect.size = CGSizeMake(self.bounds.size.width - 2.0f * _style.borderWidth,
                    self.bounds.size.height - (_style.arrowHeight + 2.0f * _style.borderWidth));
		}
    } else if (_arrowDirection == FPPopoverArrowDirectionDown) {
        contentRect.origin = CGPointMake(_style.borderWidth, _style.topBarHeight);
        contentRect.size = CGSizeMake(self.bounds.size.width - 2.0f * _style.borderWidth,
                self.bounds.size.height-(_style.arrowHeight + _style.topBarHeight + _style.bottomBarHeight));
        if (self.title == nil) {
			contentRect.origin = CGPointMake(_style.borderWidth, _style.borderWidth);
			contentRect.size = CGSizeMake(self.bounds.size.width - 2.0f * _style.borderWidth,
                    self.bounds.size.height - (_style.arrowHeight + 2.0f * _style.borderWidth));
		}
    } else if (_arrowDirection == FPPopoverArrowDirectionRight) {
        contentRect.origin = CGPointMake(_style.borderWidth, _style.topBarHeight);
        contentRect.size = CGSizeMake(self.bounds.size.width - (_style.arrowHeight + 2.0f * _style.borderWidth),
                self.bounds.size.height - (_style.topBarHeight + _style.bottomBarHeight));
        if (self.title == nil) {
            contentRect.origin = CGPointMake(_style.borderWidth, _style.borderWidth);
			contentRect.size = CGSizeMake(self.bounds.size.width - (_style.arrowHeight + 2.0f * _style.borderWidth),
                    self.bounds.size.height - 2.0f * _style.borderWidth);
		}
    } else if (_arrowDirection == FPPopoverArrowDirectionLeft) {
        contentRect.origin = CGPointMake(_style.borderWidth + _style.arrowHeight, _style.topBarHeight);
        contentRect.size = CGSizeMake(self.bounds.size.width - (_style.arrowHeight + 2.0f * _style.borderWidth),
                self.bounds.size.height - (_style.topBarHeight + _style.bottomBarHeight));
        if (self.title == nil) {
			contentRect.origin = CGPointMake(_style.borderWidth + _style.arrowHeight, _style.borderWidth);
            contentRect.size = CGSizeMake(self.bounds.size.width - (_style.arrowHeight + 2.0f * _style.borderWidth),
                    self.bounds.size.height - 2.0f * _style.borderWidth);
		}
    }

    if ([_style frameView]) {
        [_style frameView].frame = contentRect;
        contentRect.origin.x += [_style contentFrameInset].width;
        contentRect.origin.y += [_style contentFrameInset].height;
        contentRect.size.width -= 2.0f * [_style contentFrameInset].width;
        contentRect.size.height -= 2.0f * [_style contentFrameInset].height;
    }
    if (_style.overlayView) {
        _style.overlayView.frame = contentRect;
    }
    _contentView.frame = contentRect;
    [self updateContentStretch];
    [self updateLeftButtonFrame];
    [self updateRightButtonFrame];
    [self updateTopCentreViewFrame];
    [self updateBottomBarButtonFrames];
    [self updateTitleLabel];
}

- (void)updateContentStretch {
    CGRect stretch = { CGPointZero, _contentView.frame.size };
    CGSize fullSize = CGSizeZero;
    
    if (FPPopoverArrowDirectionIsVertical(_arrowDirection)) {
        fullSize.width = _contentView.frame.size.width + 2.0f * _style.borderWidth;
        fullSize.height = _contentView.frame.size.height + _style.arrowHeight + _style.topBarHeight + _style.bottomBarHeight;
        stretch.origin.x = _style.borderWidth;
        
        if (_arrowDirection == FPPopoverArrowDirectionUp) {
            stretch.origin.y = _style.arrowHeight + _style.topBarHeight;
        } else {
            stretch.origin.y = _style.topBarHeight;
        }
    } else {
        fullSize.width = _contentView.frame.size.width + _style.arrowHeight + 2.0f * _style.borderWidth;
        fullSize.height = _contentView.frame.size.height + _style.topBarHeight + _style.bottomBarHeight;
        stretch.origin.y = _style.topBarHeight;
        
        if (_arrowDirection == FPPopoverArrowDirectionLeft) {
            stretch.origin.x = _style.arrowHeight + _style.borderWidth;
        } else {
            stretch.origin.x = _style.borderWidth;
        }
    }
    
    if (fullSize.width <= 0.0f ||
        fullSize.height <= 0.0f) {
        return;
    }
    
    self.contentStretch = CGRectMake(stretch.origin.x / fullSize.width,
                                     stretch.origin.y / fullSize.height,
                                     stretch.size.width / fullSize.width,
                                     stretch.size.height / fullSize.height);
}

- (void)updateTitleLabel {
    _titleLabel.text = self.title;
    if (self.title != nil && _arrowDirection != 0) {
        CGRect titleFrame = CGRectZero;
        
        if (_arrowDirection == FPPopoverArrowDirectionUp) {
            titleFrame = CGRectMake(_style.borderWidth, _style.arrowHeight + _style.borderWidth,
                                           self.bounds.size.width - 2.0f * _style.borderWidth, _style.topBarHeight - 2.0f * _style.borderWidth);
        } else if (_arrowDirection == FPPopoverArrowDirectionDown) {
            titleFrame = CGRectMake(_style.borderWidth, _style.borderWidth,
                                           self.bounds.size.width - 2.0f * _style.borderWidth, _style.topBarHeight - 2.0f * _style.borderWidth);
        } else if (_arrowDirection == FPPopoverArrowDirectionRight) {
            titleFrame = CGRectMake(_style.borderWidth, _style.borderWidth,
                                           self.bounds.size.width - (_style.arrowHeight + 2.0f * _style.borderWidth),
                                           _style.topBarHeight - 2.0f * _style.borderWidth);
        } else if (_arrowDirection == FPPopoverArrowDirectionLeft) {
            titleFrame = CGRectMake(_style.borderWidth + _style.arrowHeight, _style.borderWidth,
                                           self.bounds.size.width - (_style.arrowHeight + 2.0f * _style.borderWidth),
                                           _style.topBarHeight - 2.0f * _style.borderWidth);
        }
        
        CGFloat widthAvailableForTitle = titleFrame.size.width;
        CGFloat widthReductionForButtons = 0.0f;
        
        if (leftButton || rightButton) {
            widthReductionForButtons = MAX(leftButton.frame.size.width, rightButton.frame.size.width) + TitleHorizontalPadding;
            widthReductionForButtons *= 2.0f;
        }
        widthAvailableForTitle -= widthReductionForButtons;
        
        CGFloat adjustedFontSize;
        
        [title sizeWithFont:_style.titleFont
                minFontSize:8.0f
             actualFontSize:&adjustedFontSize
                   forWidth:widthAvailableForTitle
              lineBreakMode:UILineBreakModeTailTruncation];
        _titleLabel.font = [_titleLabel.font fontWithSize:adjustedFontSize];
        _titleLabel.frame = titleFrame;
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self setupViews];
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setupViews];
}

-(void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self setupViews];
}

- (FPTouchedOutsideBlock)touchedOutsideBlock {
    FPTouchedOutsideBlock block = ^{
        if (animationTimer != nil) {
            [animationTimer invalidate];
            animationTimer = nil;
        }
        animationStartTime = [[NSDate date] timeIntervalSinceReferenceDate];
        animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.0167f
                                                          target:self
                                                        selector:@selector(styleAnimation:)
                                                        userInfo:nil
                                                         repeats:YES];
    };
    return [[block copy] autorelease];
}

- (void)styleAnimation:(NSTimer*)timer {
    NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];
    NSTimeInterval interval = now - animationStartTime;
    CGFloat portion = 0.0f;
    
    if (interval <= StylingAnimationDurationIn) {
        portion = (CGFloat)(interval / StylingAnimationDurationIn);
        portion = fade(portion);
    } else if (interval <= StylingAnimationDurationIn + StylingAnimationDurationPause) {
        portion = 1.0f;
    } else if (interval <= StylingAnimationDurationIn + StylingAnimationDurationPause + StylingAnimationDurationOut) {
        portion = 1.0f - ((interval - (StylingAnimationDurationIn + StylingAnimationDurationPause)) / StylingAnimationDurationOut);
        portion = fade(portion);
    } else {
        [animationTimer invalidate];
        animationTimer = nil;
        return;
    }
    
    [_style animateWithPortion:portion];
    self.layer.shadowOpacity = _style.shadowOpacity;
    self.layer.shadowColor = _style.shadowColor.CGColor;
    self.layer.shadowRadius = _style.shadowRadius;
    [self setNeedsDisplay];
}

@end
