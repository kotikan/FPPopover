//
//  FPPopoverView.m
//
//  Created by Alvise Susmel on 1/4/12.
//  Copyright (c) 2012 Fifty Pixels Ltd. All rights reserved.
//
//  https://github.com/50pixels/FPPopover


#import "FPPopoverView.h"
#import "FPPopoverStyle.h"
#import "FPPopoverBlackStyle.h"
#import "FPPopoverLightGrayStyle.h"
#import "FPPopoverGreenStyle.h"
#import "FPPopoverRedStyle.h"

@interface FPPopoverView(Private)
-(void)setupViews;
@end


@implementation FPPopoverView {
    UIButton *leftButton;
    UIButton *rightButton;
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
    if ([_style frameView]) {
        [self addSubview:[_style frameView]];
        if (_contentView) {
            [_style frameView].backgroundColor = _contentView.backgroundColor;
            [self bringSubviewToFront:_contentView];
        }
    }
    if (_style.contentCornerRadius > 0.0f && _contentView) {
        [_contentView.layer setCornerRadius:_style.contentCornerRadius];
        [_contentView.layer setMasksToBounds:YES];
    }
    [self setupViews];
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
        if ([_style frameView]) {
            [_style frameView].backgroundColor = _contentView.backgroundColor;
        }
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
    [self addSubview:rightButton];
    [self updateRightButtonFrame];
}

- (void)updateRightButtonFrame {
    CGRect outerRect = [self outerRectForBorderWidth:1.0f];
    CGRect rightButtonFrame = CGRectMake(outerRect.origin.x + outerRect.size.width - (rightButton.frame.size.width + _style.borderWidth),
                                         outerRect.origin.y + _style.borderWidth,
                                         rightButton.frame.size.width,
                                         rightButton.frame.size.height);
    
    rightButton.frame = rightButtonFrame;
}

- (void)updateLeftButtonFrame {
    CGRect outerRect = [self outerRectForBorderWidth:1.0f];
    CGRect leftButtonFrame = CGRectMake(outerRect.origin.x + _style.borderWidth,
                                        outerRect.origin.y + _style.borderWidth,
                                        leftButton.frame.size.width,
                                        leftButton.frame.size.height);
    
    leftButton.frame = leftButtonFrame;
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
    if (ax < aw + b) {
        ax = aw + b;
    } else if (ax +2*aw + 2*b> self.bounds.size.width) {
        ax = self.bounds.size.width - 2*aw - 2*b;
    }

    //ROUNDED RECT
    // arrow UP
    CGRect innerRect = CGRectInset(rect, radius, radius);
    CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
    CGFloat inside_left = innerRect.origin.x;
    CGFloat inside_top = innerRect.origin.y;
    CGFloat outside_top = rect.origin.y;
    CGMutablePathRef path = CGPathCreateMutable();
    UIBezierPath *quarterCircle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(inside_left, inside_top)
                                                                 radius:radius
                                                             startAngle:5.0f * M_PI / 4.0f
                                                               endAngle:3.0f * M_PI / 2.0f
                                                              clockwise:YES];
    CGPathAddPath(path, NULL, quarterCircle.CGPath);
    if(_arrowDirection == FPPopoverArrowDirectionUp) {
        CGPathAddLineToPoint(path, NULL, ax, ah+b);
        CGPathAddLineToPoint(path, NULL, ax+aw, b);
        CGPathAddLineToPoint(path, NULL, ax+2*aw, ah+b);
    }
    CGPathAddLineToPoint(path, NULL, inside_right, outside_top);
    quarterCircle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(inside_right, inside_top)
                                                   radius:radius
                                               startAngle:3.0f * M_PI / 2.0f
                                                 endAngle:7.0f * M_PI / 4.0f
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
    if (ax < aw + b) {
        ax = aw + b;
    } else if (ax +2*aw + 2*b> self.bounds.size.width) {
        ax = self.bounds.size.width - 2*aw - 2*b;
    }

    CGFloat ay = self.relativeOrigin.y - aw; //the start of the arrow when RIGHT or LEFT
    if (ay < aw + b) {
        ay = aw + b;
    } else if (ay +2*aw + 2*b > self.bounds.size.height) {
        ay = self.bounds.size.height - 2*aw - 2*b;
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

    CGPathRef contentPath = [self newContentPathWithBorderWidth:2.0];
    CGContextAddPath(ctx, contentPath);
    CGContextClip(ctx);
    [self drawHeaderGradient:ctx];
    [self drawMainFill:ctx];
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
    CGPathRef topEdgePath = [self newTopEdgePathWithBorderWidth:3.0];
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
    CGFloat startY = self.bounds.size.height - [_style bottomBarHeight];
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

- (void)drawMainFill:(CGContextRef)ctx {
    UIColor *fillColor = [_style borderColor];
    CGFloat startY = [_style topBarGradientHeight];
    if (_arrowDirection == FPPopoverArrowDirectionUp) {
        startY += [_style arrowHeight];
    }
    CGFloat height = self.bounds.size.height - startY;

    CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
    if ([_style bottomBarGradientHeight] > 0.0f) {
        height -= [_style bottomBarHeight];
        if (_arrowDirection == FPPopoverArrowDirectionDown) {
            height -= [_style arrowHeight];
        }
    }
    CGContextFillRect(ctx, CGRectMake(0, startY, self.bounds.size.width, height));
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
        _titleLabel.frame = CGRectMake(_style.borderWidth, _style.arrowHeight + _style.borderWidth,
                self.bounds.size.width - 2.0f * _style.borderWidth, _style.topBarHeight - 2.0f * _style.borderWidth);
		if (self.title == nil || self.title.length == 0) {
			contentRect.origin = CGPointMake(_style.borderWidth, _style.arrowHeight + _style.borderWidth);
			contentRect.size = CGSizeMake(self.bounds.size.width - 2.0f * _style.borderWidth,
                    self.bounds.size.height - (_style.arrowHeight + 2.0f * _style.borderWidth));
		}
    } else if (_arrowDirection == FPPopoverArrowDirectionDown) {
        contentRect.origin = CGPointMake(_style.borderWidth, _style.topBarHeight);
        contentRect.size = CGSizeMake(self.bounds.size.width - 2.0f * _style.borderWidth,
                self.bounds.size.height-(_style.arrowHeight + _style.topBarHeight + _style.bottomBarHeight));
        _titleLabel.frame = CGRectMake(_style.borderWidth, _style.borderWidth,
                self.bounds.size.width - 2.0f * _style.borderWidth, _style.topBarHeight - 2.0f * _style.borderWidth);
        if (self.title == nil || self.title.length == 0) {
			contentRect.origin = CGPointMake(_style.borderWidth, _style.borderWidth);
			contentRect.size = CGSizeMake(self.bounds.size.width - 2.0f * _style.borderWidth,
                    self.bounds.size.height - (_style.arrowHeight + 2.0f * _style.borderWidth));
		}
    } else if (_arrowDirection == FPPopoverArrowDirectionRight) {
        contentRect.origin = CGPointMake(_style.borderWidth, _style.topBarHeight);
        contentRect.size = CGSizeMake(self.bounds.size.width - (_style.arrowHeight + 2.0f * _style.borderWidth),
                self.bounds.size.height - (_style.topBarHeight + _style.bottomBarHeight));
        _titleLabel.frame = CGRectMake(_style.borderWidth, _style.borderWidth,
                self.bounds.size.width - (_style.arrowHeight + 2.0f * _style.borderWidth),
                _style.topBarHeight - 2.0f * _style.borderWidth);
        if (self.title == nil || self.title.length == 0) {
            contentRect.origin = CGPointMake(_style.borderWidth, _style.borderWidth);
			contentRect.size = CGSizeMake(self.bounds.size.width - (_style.arrowHeight + 2.0f * _style.borderWidth),
                    self.bounds.size.height - 2.0f * _style.borderWidth);
		}
    } else if (_arrowDirection == FPPopoverArrowDirectionLeft) {
        contentRect.origin = CGPointMake(_style.borderWidth + _style.arrowHeight, _style.topBarHeight);
        contentRect.size = CGSizeMake(self.bounds.size.width - (_style.arrowHeight + 2.0f * _style.borderWidth),
                self.bounds.size.height - (_style.topBarHeight + _style.bottomBarHeight));
        _titleLabel.frame = CGRectMake(_style.borderWidth + _style.arrowHeight, _style.borderWidth,
                self.bounds.size.width - (_style.arrowHeight + 2.0f * _style.borderWidth),
                _style.topBarHeight - 2.0f * _style.borderWidth);
        if (self.title == nil || self.title.length == 0) {
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
    _contentView.frame = contentRect;
    _titleLabel.text = self.title;
    [self updateLeftButtonFrame];
    [self updateRightButtonFrame];
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

@end
