//
//  ThrustControl.h
//  ripoff
//
//  Created by Andrew Cruse on 11/03/13.
//  Copyright (c) 2013 Andrew Cruse. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThrustControl;

@protocol ThrustControlDelegate <NSObject>

@required

-(void) thrustControlValueChanged:(ThrustControl *) thrustControl;

@end

@interface ThrustControl : UIView

@property (nonatomic, weak) IBOutlet id <ThrustControlDelegate> delegate;
@property (nonatomic) double thrust;
@property (nonatomic) double angle;

-(void) touchMovedTo:(CGPoint) location;

@end
