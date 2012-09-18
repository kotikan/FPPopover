//
// FPPopoverAccessoriesProtocol
// Skyscanner
//
// Created by jock on 18/09/2012.
// Copyright (c) 2012 Kotikan. All rights reserved.
//

@protocol FPPopoverAccessoriesProtocol <NSObject>

@optional
- (NSArray *)bottomBarButtons;
- (UIButton *)leftTopBarButton;
- (UIButton *)rightTopBarButton;

@end