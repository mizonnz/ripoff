//
//  ViewController.m
//  ripoff
//
//  Created by Andrew Cruse on 9/03/13.
//  Copyright (c) 2013 Andrew Cruse. All rights reserved.
//

#import "ViewController.h"

#define PLAYERSPEED 5.0
#define PLAYERFRICTION 0.95

@interface ViewController ()

@end

@implementation ViewController


#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.playerVector=CGPointMake(0,0);
    self.touchDown=NO;
    self.leftButtonDown=NO;
    self.rightButtonDown=NO;
    self.thrustButtonDown=NO;
//    [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(gameTimer) userInfo:nil repeats:YES];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(gameTimer)];
    [self.displayLink setFrameInterval:1];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
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

-(void) thrustControlValueChanged:(ThrustControl *)thrustControl
{
    if (thrustControl.thrust==0)
    {
        self.touchDown=NO;
    }
    else
    {
        self.touchDown=YES;
    }
}

#pragma mark Game Events

-(void) gameTimer
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);  //dispatch_queue_create("gameUpdate", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async (queue, ^(void){
        if (self.currentControl.selectedSegmentIndex==1)
        {
            double vectorAngle=atan2(self.playerVector.y, self.playerVector.x);
            double vectorDistance=sqrt((self.playerVector.x*self.playerVector.x)+(self.playerVector.y*self.playerVector.y));
            if (self.leftButtonDown) vectorAngle=vectorAngle-0.05;
            if (self.rightButtonDown) vectorAngle=vectorAngle+0.05;
            if (self.thrustButtonDown) vectorDistance=PLAYERSPEED;
            self.playerVector=CGPointMake(cos(vectorAngle)*vectorDistance, sin(vectorAngle)*vectorDistance);
        }
        if (self.currentControl.selectedSegmentIndex==2 && self.touchDown)
        {
            double thrust=self.thrustControl.thrust/(self.thrustControl.bounds.size.height);
            double vectorAngle=atan2(self.playerVector.y, self.playerVector.x);
            vectorAngle=vectorAngle+(self.thrustControl.angle*0.1);
            self.playerVector=CGPointMake(cos(vectorAngle)*thrust*PLAYERSPEED, sin(vectorAngle)*thrust*PLAYERSPEED);
        }
        CGPoint player=self.playerView.center;
        if (!self.touchDown) self.playerVector=CGPointMake(self.playerVector.x*PLAYERFRICTION, self.playerVector.y*PLAYERFRICTION);
        player=CGPointMake(player.x+self.playerVector.x, player.y+self.playerVector.y);
        double playerAngle=atan2(-self.playerVector.y, -self.playerVector.x);
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^(void){
            CGPoint oldcentre=self.playerView.center;
            self.playerView.center=player;
            if (!CGRectContainsRect(self.gameView.bounds, self.playerView.frame)) self.playerView.center=oldcentre;
            self.playerView.transform=CGAffineTransformMakeRotation(playerAngle);
        });
    });
//    dispatch_release(queue);
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
        self.thrustControl.hidden=YES;
    }
    if (self.currentControl.selectedSegmentIndex==1)
    {
        self.controlsLabel.text=@"Use buttons";
        self.leftButton.hidden=NO;
        self.rightButton.hidden=NO;
        self.thrustButton.hidden=NO;
        self.thrustControl.hidden=YES;
    }
    if (self.currentControl.selectedSegmentIndex==2)
    {
        self.controlsLabel.text=@"Thrust Controller";
        self.leftButton.hidden=YES;
        self.rightButton.hidden=YES;
        self.thrustButton.hidden=YES;
        self.thrustControl.hidden=NO;
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
