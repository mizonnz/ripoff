//
//  ViewController.h
//  ripoff
//
//  Created by Andrew Cruse on 9/03/13.
//  Copyright (c) 2013 Andrew Cruse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ThrustControl.h"

@interface ViewController : UIViewController <ThrustControlDelegate>

@property (strong, nonatomic) IBOutlet UIView *gameView;
@property (strong, nonatomic) IBOutlet UIImageView *playerView;
@property CGPoint playerVector;
@property BOOL touchDown;
@property (strong, nonatomic) IBOutlet UILabel *controlsLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *currentControl;
@property (strong, nonatomic) IBOutlet UIButton *leftButton;
@property (strong, nonatomic) IBOutlet UIButton *rightButton;
@property (strong, nonatomic) IBOutlet UIButton *thrustButton;
@property BOOL leftButtonDown;
@property BOOL rightButtonDown;
@property BOOL thrustButtonDown;
@property (strong, nonatomic) IBOutlet ThrustControl *thrustControl;
@property (strong, nonatomic) CADisplayLink *displayLink;

-(void) gameTimer;
-(void) movePlayerTo:(CGPoint) location;
-(void) thrustControlValueChanged:(ThrustControl *)thrustControl;

- (IBAction)changedControls:(id)sender;
- (IBAction)LeftButtonPressed:(id)sender;
- (IBAction)leftButtonReleased:(id)sender;
- (IBAction)rightButtonPressed:(id)sender;
- (IBAction)rightButtonReleased:(id)sender;
- (IBAction)thrustButtonPressed:(id)sender;
- (IBAction)thrustButtonReleased:(id)sender;


@end
