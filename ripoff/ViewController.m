//
//  ViewController.m
//  ripoff
//
//  Created by Andrew Cruse on 9/03/13.
//  Copyright (c) 2013 Andrew Cruse. All rights reserved.
//

#import "ViewController.h"

#define PLAYERSPEED 0.05
#define PLAYERFRICTION 0.999

@interface ViewController ()

@end

@implementation ViewController


#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [NSTimer scheduledTimerWithTimeInterval:1/30 target:self selector:@selector(gameTimer) userInfo:nil repeats:YES];
    self.playerVector=CGPointMake(-.01, 0.005);
    self.touchDown=NO;
    self.leftButtonDown=NO;
    self.rightButtonDown=NO;
    self.thrustButtonDown=NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Touch Events

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touchDown=YES;
    UITouch *touch=[touches anyObject];
    CGPoint location=[touch locationInView:self.gameView];
    [self movePlayerTo:location];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=[touches anyObject];
    CGPoint location=[touch locationInView:self.gameView];
    [self movePlayerTo:location];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touchDown=NO;
}


#pragma mark Game Events

-(void) gameTimer
{
    if (self.currentControl.selectedSegmentIndex==1)
    {
        double vectorAngle=atan2(self.playerVector.y, self.playerVector.x);
        double vectorDistance=sqrt((self.playerVector.x*self.playerVector.x)+(self.playerVector.y*self.playerVector.y));
        if (self.leftButtonDown) vectorAngle=vectorAngle-0.005;
        if (self.rightButtonDown) vectorAngle=vectorAngle+0.005;
        if (self.thrustButtonDown) vectorDistance=PLAYERSPEED;
        self.playerVector=CGPointMake(cos(vectorAngle)*vectorDistance, sin(vectorAngle)*vectorDistance);
    }
    CGPoint player=self.playerView.center;
    if (!self.touchDown) self.playerVector=CGPointMake(self.playerVector.x*PLAYERFRICTION, self.playerVector.y*PLAYERFRICTION);
    player=CGPointMake(player.x+self.playerVector.x, player.y+self.playerVector.y);
    double playerAngle=atan2(-self.playerVector.y, -self.playerVector.x);
    self.playerView.center=player;
    self.playerView.transform=CGAffineTransformMakeRotation(playerAngle);
}

-(void) movePlayerTo:(CGPoint) location
{
    if (self.currentControl.selectedSegmentIndex==0)
    {
        CGPoint difference=CGPointMake(self.playerView.center.x-location.x, self.playerView.center.y-location.y);
        double angle=atan2(difference.y, difference.x);
        self.playerVector=CGPointMake(-cos(angle)*PLAYERSPEED, -sin(angle)*PLAYERSPEED);
    }
}

- (IBAction)changedControls:(id)sender {
    if (self.currentControl.selectedSegmentIndex==0)
    {
        self.controlsLabel.text=@"Player follows your finger";
        self.leftButton.hidden=YES;
        self.rightButton.hidden=YES;
        self.thrustButton.hidden=YES;
    }
    if (self.currentControl.selectedSegmentIndex==1)
    {
        self.controlsLabel.text=@"Use buttons";
        self.leftButton.hidden=NO;
        self.rightButton.hidden=NO;
        self.thrustButton.hidden=NO;
    }
}

- (IBAction)LeftButtonPressed:(id)sender {
    self.leftButtonDown=YES;
}

- (IBAction)leftButtonReleased:(id)sender {
    self.leftButtonDown=NO;
}

- (IBAction)rightButtonPressed:(id)sender {
    self.rightButtonDown=YES;
}

- (IBAction)rightButtonReleased:(id)sender {
    self.rightButtonDown=NO;
}

- (IBAction)thrustButtonPressed:(id)sender {
    self.thrustButtonDown=YES;
}

- (IBAction)thrustButtonReleased:(id)sender {
    self.thrustButtonDown=NO;
}

@end
