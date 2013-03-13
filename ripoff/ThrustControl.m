//
//  ThrustControl.m
//  ripoff
//
//  Created by Andrew Cruse on 11/03/13.
//  Copyright (c) 2013 Andrew Cruse. All rights reserved.
//

#import "ThrustControl.h"

@implementation ThrustControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=[touches anyObject];
    CGPoint location=[touch locationInView:self];
    [self touchMovedTo:location];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=[touches anyObject];
    CGPoint location=[touch locationInView:self];
    [self touchMovedTo:location];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.thrust=0;
    [self.delegate thrustControlValueChanged:self];    
}

-(void) touchMovedTo:(CGPoint)location
{
    float width=self.bounds.size.width;
    float height=self.bounds.size.height;
    float xDiff=location.x-(width/2);
    float yDiff=height-location.y;
    float thrust=sqrt((xDiff*xDiff)+(yDiff*yDiff));
    float angle=atan2(xDiff, yDiff);
//    NSLog(@"Position %0.0fx%0.0f gave thrust %0.0f and angle %0.0f",location.x,location.y,thrust,angle*(180/M_PI));
    self.thrust=thrust;
    self.angle=angle;
    [self.delegate thrustControlValueChanged:self];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    float width=self.bounds.size.width;
    float height=self.bounds.size.height;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextSetLineWidth(context, 2);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, width, 0);
    CGContextAddLineToPoint(context, width/2, height);
    CGContextAddLineToPoint(context, 0, 0);
    CGContextStrokePath(context);    
}


@end
