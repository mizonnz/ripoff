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
    self.cattle=[NSMutableArray array];
    for (int i=0; i<8; i++) {
        UIImageView *cow=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Cattle.png"]];
        cow.center=CGPointMake( 130+(65*(i>3)),(i%4) * 30+100);
        [self.cattle addObject:cow];
        [self.gameView addSubview:cow];
    }
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

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation==UIDeviceOrientationLandscapeLeft || toInterfaceOrientation==UIDeviceOrientationLandscapeRight) {
        self.thrustControl.center=CGPointMake(self.thrustControl.bounds.size.width/2,self.thrustControl.bounds.size.height); // iphone & ipad landscape (top left corner, but down a bit)
    } else {
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        {
            self.thrustControl.center=CGPointMake(84, 885);  // ipad portrait (values from .xib file)
        } else {
            self.thrustControl.center=CGPointMake(44, 410);  // iphone portrait (values from .xib file)
        }
    }
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
        
        if (CGRectIntersectsRect(self.playerView.frame, self.enemyView.frame))
        {
            self.cowHeldByEnemy=nil;
            self.enemyView.center=CGPointMake(20, 20);
        }
        
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
        
        CGPoint enemy=self.enemyView.center;
        float enemyAngle=0;
        if (self.cowHeldByEnemy==nil)
        {
            float dist=99999;
            UIImageView *nearestCow=nil;
            for (UIImageView *checkCow in self.cattle) {
                float diffX=checkCow.center.x-self.enemyView.center.x;
                float diffY=checkCow.center.y-self.enemyView.center.y;
                float diff=(diffX*diffX)+(diffY*diffY);
                if (diff<dist)
                {
                    dist=diff;
                    nearestCow=checkCow;
                }
            }
            float diffX=nearestCow.center.x-self.enemyView.center.x;
            float diffY=nearestCow.center.y-self.enemyView.center.y;
            enemyAngle=atan2(diffY, diffX);
            enemy=CGPointMake(enemy.x+cos(enemyAngle), enemy.y+sin(enemyAngle));
            if (dist<100) self.cowHeldByEnemy=nearestCow;  // if distane is less than 10 (sqrt 100) grab the cow
        } else {
            float topDist=self.enemyView.center.y;
            float bottomDist=self.gameView.bounds.size.height-self.enemyView.center.y;
            float leftDist=self.enemyView.center.x;
            float rightDist=self.gameView.bounds.size.width-self.enemyView.center.x;
            if (topDist<bottomDist && topDist<leftDist && topDist<rightDist) enemyAngle=1.5*M_PI;
            if (bottomDist<topDist && bottomDist<leftDist && bottomDist<rightDist) enemyAngle=0.5*M_PI;
            if (leftDist<topDist && leftDist<bottomDist && leftDist<rightDist) enemyAngle=M_PI;
            if (rightDist<topDist && rightDist<bottomDist && rightDist<leftDist) enemyAngle=0;
            enemy=CGPointMake(enemy.x+cos(enemyAngle), enemy.y+sin(enemyAngle));
            if (topDist<0 || bottomDist<0 || leftDist<0 || rightDist<0)
            {
                [self.cowHeldByEnemy removeFromSuperview];
                [self.cattle removeObject:self.cowHeldByEnemy];
                self.cowHeldByEnemy=nil;
            }
        }
        
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^(void){
            CGPoint oldcentre=self.playerView.center;
            self.playerView.center=player;
            if (!CGRectContainsRect(self.gameView.bounds, self.playerView.frame)) self.playerView.center=oldcentre;
            self.playerView.transform=CGAffineTransformMakeRotation(playerAngle);
            self.enemyView.center=enemy;
            self.enemyView.transform=CGAffineTransformMakeRotation(enemyAngle+M_PI);
            if (self.cowHeldByEnemy)
            {
                float cowX=self.enemyView.center.x-(cos(enemyAngle)*20);
                float cowY=self.enemyView.center.y-(sin(enemyAngle)*20);
                self.cowHeldByEnemy.center=CGPointMake(cowX, cowY);
                self.cowHeldByEnemy.transform=CGAffineTransformMakeRotation(enemyAngle+M_PI);
            }
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

- (void)viewDidUnload {
    [self setEnemyView:nil];
    [super viewDidUnload];
}
@end
