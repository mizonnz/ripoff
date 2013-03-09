//
//  ViewController.h
//  ripoff
//
//  Created by Andrew Cruse on 9/03/13.
//  Copyright (c) 2013 Andrew Cruse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

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

-(void) gameTimer;
-(void) movePlayerTo:(CGPoint) location;
- (IBAction)changedControls:(id)sender;
- (IBAction)LeftButtonPressed:(id)sender;
- (IBAction)leftButtonReleased:(id)sender;
- (IBAction)rightButtonPressed:(id)sender;
- (IBAction)rightButtonReleased:(id)sender;
- (IBAction)thrustButtonPressed:(id)sender;
- (IBAction)thrustButtonReleased:(id)sender;

@end
