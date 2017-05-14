//
//  Knob.m
//  Knob
//
//  Created by Ulrich Winkler on 13.05.17.
//  Copyright © 2017 Kodira. All rights reserved.
//

#import "Knob.h"

#define DEFAULT_SEGMENT_ANGLE          18.0
#define DEFAULT_SEGEMENT_PADDIG_ANGLE  2.0

#define DIAL_ARROW_WIDTH  20
#define DIAL_ARROW_HEIGHT 40

#define DIAL_BORDER  4


double radians(double degrees) {
    return degrees * M_PI / 180;
}

@interface Knob ()

@property (nonatomic) CGFloat angle;
@property CGRect rect;
@property BOOL didLayoutDialLayer;
@property UIView* dialLayer;
@property UIImageView* coverImageView;
@property (readonly, nonatomic) UIColor* currentSelectedColor;

@end

@implementation Knob

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing 
 
 
*/

-(instancetype)init {
    self = [super init];
    if ( self ) {
        [self setup];
    }
    return self;

}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup {
    self.backgroundColor = [UIColor darkGrayColor];
    self.colors = @[ @0x5739f1, @0x3973f1, @0x399ff1, @0x39cff1, @0xaf39f1, @0xdc39f1, @0xf139c6, @0xd40092, @0xececec,
                     @0x55f139, @0xa0f139, @0xe1f139, @0xf1e039, @0xf1a839, @0xf16939, @0xf15639, @0xf13f39
    ];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouch:)];
    [self addGestureRecognizer:tapGesture];
    
    
    UIPanGestureRecognizer *swipeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouch:)];
    [self addGestureRecognizer:swipeGesture];
    
    
    self.dialLayer = [[Dial alloc] initWithFrame:CGRectMake(0 ,0 , DIAL_ARROW_WIDTH, DIAL_ARROW_HEIGHT)];
    self.dialLayer.opaque = NO;
    [self addSubview:self.dialLayer];
    self.dialLayer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.dialLayer.layer.shadowOffset = CGSizeMake(0.5, 0.4);  //Here you control x and y
    self.dialLayer.layer.shadowOpacity = 0.5;
    self.dialLayer.layer.shadowRadius = 5.0; //Here your control your blur
    
    self.coverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cover"]];
    [self addSubview:self.coverImageView];
    self.coverImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.coverImageView.layer.shadowOffset = CGSizeMake(0, 0);
    self.coverImageView.layer.shadowOpacity = 1;
    self.coverImageView.layer.shadowRadius = 10.0; //Here your control the glow (show blur)
    
}


-(void)layoutSubviews {
    if ( ! _didLayoutDialLayer) {
        double width = (self.dialRadius * 2 + DIAL_ARROW_WIDTH * 2 - 2);
        self.dialLayer.frame = CGRectMake(self.center.x - width / 2 , self.center.y - DIAL_ARROW_HEIGHT/2, width , DIAL_ARROW_HEIGHT);
        self.coverImageView.frame = CGRectMake(
            self.center.x - self.dialRadius + DIAL_BORDER / 2,
            self.center.y - self.dialRadius + DIAL_BORDER / 2,
            self.dialRadius * 2 - DIAL_BORDER,
            self.dialRadius * 2 - DIAL_BORDER
        );
        self.didLayoutDialLayer = YES;
    }
}



- (void)drawRect:(CGRect)rect {
    self.rect = rect;
    [self drawColorWheel];
    [self drawDialRing];
//    [self drawDialCover];
}


-(void) drawDialRing {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, self.center.x, self.center.y);
    CGContextAddArc(context,self.center.x , self.center.y, self.dialRadius + 2,  radians(0), radians(360), false );
    CGContextSetFillColorWithColor(context, self.dialColor.CGColor);
    CGContextFillPath(context);
}


-(void) drawColorWheel {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    
    double startAngle = [self getStartAngle];

    for (NSNumber* color in self.colors) {
        double endAngle = startAngle + [self segementAngle];
        CGContextMoveToPoint(context, self.center.x, self.center.y);
        CGContextAddArc(context,self.center.x , self.center.y, self.colorWheelOutterRadius,  radians(startAngle), radians(endAngle), false );
        CGContextSetFillColorWithColor(context, [UIColor colorwithHex:color alpha:1.0f].CGColor);
        CGContextFillPath(context);
        startAngle += [self segementAngle] + [self segementPaddingAngle];
    }
    
    CGContextMoveToPoint(context, self.center.x, self.center.y);
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGContextAddArc(context,self.center.x , self.center.y, self.colorWheelInnerRadius,  radians(0), radians(360), false );
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillPath(context);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
}

-(void) clearDrawing{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, self.rect.size.width, self.rect.size.height));
}


-(void) handleTouch:(UIGestureRecognizer *)recognizer{
    CGPoint location = [recognizer locationInView:recognizer.view];
    NSLog(@"Tap: %f, %f", location.x, location.y);
    NSLog(@"Center: %f, %f", self.center.x, self.center.y);
    NSLog(@"Angle:%f", [self angleFromCenter:location]);
    NSLog(@"StartAngle:%f", [self getStartAngle]);
    

    self.angle = [self angleFromCenter:location];

//    [self setNeedsDisplay];
    
    if(recognizer.state == UIGestureRecognizerStateEnded) {
        self.angle = [self getClosedSegemntCenterAngle];
        NSLog(@"END");
    }
        [UIView animateWithDuration:0.2
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [UIView setAnimationBeginsFromCurrentState:YES];
                         self.dialLayer.transform = CGAffineTransformMakeRotation(radians(self.angle));
                         self.coverImageView.layer.shadowColor = self.currentSelectedColor.CGColor;
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
    
}


- (double) getClosedSegemntCenterAngle {
    int idx = [self currentSelectedIndex];
    return  [self getStartAngle] +  idx * self.segementAngle + idx * self.segementPaddingAngle + self.segementAngle / 2 ;
}

- (UIColor*) currentSelectedColor {
    NSNumber* color = [self.colors objectAtIndex:[self currentSelectedIndex]];
    return [UIColor colorwithHex:color alpha:1.0];
}

- (int) currentSelectedIndex {
    double startAngle = [self getStartAngle];
    int segement = 0;
    int maxDelta = INT_MAX;
    for (int i = 0; i < [self.colors count]; i++) {
        double currentSegmentCenterAngle = startAngle +  i * self.segementAngle + i * self.segementPaddingAngle + self.segementAngle / 2 ;
        int currentSegmentCenterAngleNormalized = ((int)currentSegmentCenterAngle + 360) % 360;
        int angleNormalized = ((int)self.angle + 360) % 360;
        int delta = abs( currentSegmentCenterAngleNormalized - angleNormalized);
        if ( maxDelta > MIN(maxDelta, delta)){
            maxDelta = MIN(maxDelta, delta);
            segement = i;
        }
    }
    return segement;
}


- (CGFloat) angleFromCenter:(CGPoint)point
{
    CGPoint originPoint = CGPointMake(point.x - self.center.x, point.y - self.center.y);
    float bearingRadians = atan2f(originPoint.y, originPoint.x); // get bearing in radians
    float bearingDegrees = bearingRadians * (180.0 / M_PI); // convert to degrees
    bearingDegrees = (bearingDegrees > 0.0 ? bearingDegrees : (360.0 + bearingDegrees)); // correct discontinuity
    return bearingDegrees;
}



-(double) getStartAngle {
    NSUInteger numberOfSegments = [self.colors count];
    double fullWheel = numberOfSegments * self.segementAngle + (numberOfSegments - 1 ) * self.segementPaddingAngle;
    double delta =  ( fullWheel - 180 ) / 2;
    return 360 - fullWheel + delta;
}


-(double) segementAngle {
    if ( _segementAngle) {
        return _segementAngle;
    } else {
        return  DEFAULT_SEGMENT_ANGLE;
    }
}


-(double) segementPaddingAngle {
    if (_segementPaddingAngle) {
        return _segementPaddingAngle;
    } else {
        return DEFAULT_SEGEMENT_PADDIG_ANGLE;
    }
}

-(double) colorWheelOutterRadius {
    return 110;
}

-(double) colorWheelInnerRadius {
    return 90;
}

-(double) dialRadius {
    return 80;
}

-(UIColor*) backgroundColor {
    if (_backgroundColor) {
        return _backgroundColor;
    } else {
        return [UIColor darkGrayColor];
    }
}

-(UIColor*) dialColor {
    if (_dialColor) {
        return _dialColor;
    } else {
        return [UIColor lightGrayColor];
    }
}

@end


@implementation Dial

-(void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGFloat right = self.frame.size.width - DIAL_ARROW_WIDTH;
    CGPathMoveToPoint(pathRef, NULL, right , 0);
    CGPathAddLineToPoint(pathRef, NULL, right + DIAL_ARROW_WIDTH, DIAL_ARROW_HEIGHT / 2);
    CGPathAddLineToPoint(pathRef, NULL, right, DIAL_ARROW_HEIGHT);
    CGPathCloseSubpath(pathRef);
    CGContextAddPath(context, pathRef);
    CGContextFillPath(context);
    CGContextDrawPath(context, kCGPathFill);
}


@end


@implementation UIColor (fromHex)
+ (UIColor *)colorwithHex:(NSNumber *)hex alpha:(CGFloat)alpha {
    int hexint = [hex intValue];
    return [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                           green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                            blue:((CGFloat) (hexint & 0xFF))/255
                           alpha:alpha];
}

@end
