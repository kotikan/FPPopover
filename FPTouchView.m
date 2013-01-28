//
//  FPTouchView.m
//
//  Created by Alvise Susmel on 4/16/12.
//  Copyright (c) 2012 Fifty Pixels Ltd. All rights reserved.
//
//  https://github.com/50pixels/FPPopover

#import "FPTouchView.h"

@implementation FPTouchView {
    BOOL keyboardVisible;
    CGRect keyboardRect;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter]  addObserver:self
                                                  selector:@selector(keyboardHidden:)
                                                      name:UIKeyboardDidHideNotification
                                                    object:nil];
        
        [[NSNotificationCenter defaultCenter]  addObserver:self
                                                  selector:@selector(keyboardShown:)
                                                      name:UIKeyboardDidShowNotification
                                                    object:nil];

    }
    return self;
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [_outsideBlock release];
    [_insideBlock release];
    [super dealloc];
}

- (void)keyboardShown:(NSNotification *)note {
    keyboardVisible = YES;
    NSDictionary *keyboardInfo = note.userInfo;
    NSValue *endRectValue = [keyboardInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    [endRectValue getValue:(void *)&keyboardRect];
}

- (void)keyboardHidden:(NSNotification *)note {
    keyboardVisible = NO;
}

-(void)setTouchedOutsideBlock:(FPTouchedOutsideBlock)outsideBlock
{
    [_outsideBlock release];
    _outsideBlock = [outsideBlock copy];
}

-(void)setTouchedInsideBlock:(FPTouchedInsideBlock)insideBlock
{
    [_insideBlock release];
    _insideBlock = [insideBlock copy];    
}

-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *subview = [super hitTest:point withEvent:event];

    if(UIEventTypeTouches == event.type)
    {
        BOOL touchedInside = subview != self;
        if(!touchedInside)
        {
            for(UIView *s in self.subviews)
            {
                if(s == subview)
                {
                    //touched inside
                    touchedInside = YES;
                    break;
                }
            }            
        }
        
        if(touchedInside && _insideBlock)
        {
            _insideBlock();
        }
        else if(!touchedInside && _outsideBlock)
        {
            BOOL outside = YES;
            
            if (keyboardVisible) {
                CGRect transformedKeyboardRect = [self.window convertRect:keyboardRect toView:self];

                if (CGRectContainsPoint(transformedKeyboardRect, point)) {
                    outside = NO;
                }
            }
            
            if (outside) {
                _outsideBlock();
            }
        }
    }
    
    return subview;
}


@end
