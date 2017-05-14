//
//  Knob.h
//  Knob
//
//  Created by Ulrich Winkler on 13.05.17.
//  Copyright © 2017 Kodira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Knob : UIView

@property NSArray* colors;
@property (nonatomic) UIColor* backgroundColor;
@property (nonatomic) UIColor* dialColor;

@property (nonatomic) double segementAngle;
@property (nonatomic) double segementPaddingAngle;

@property (nonatomic) double colorWheelOutterRadius;
@property (nonatomic) double colorWheelInnerRadius;

@property (nonatomic) double dialRadius;


@end


@interface Dial:UIView
@end;


@interface UIColor (fromHex)
+ (UIColor *)colorwithHex:(NSNumber *)hex alpha:(CGFloat)alpha;
@end


