//
//  C4WorkSpace.m
//  timerApp
//
//  Created by Gregory Debicki on 2013-11-25.
//

#import "C4Workspace.h"

@implementation C4WorkSpace {
    C4Shape *minUp, *minDown, *secUp, *secDown;
    NSInteger timerLength;
    C4Label *minutes, *seconds;
    C4Timer *timer;
    C4Sample *timerDoneSound;
    NSInteger storedTime;
    C4Shape *back;
    BOOL backIsBlue;
}
-(void)setup {
    back = [C4Shape ellipse:CGRectMake(0, 0, 200, 200)];
    back.center = self.canvas.center;
    back.fillColor = [UIColor whiteColor];
    back.userInteractionEnabled = NO;
    [self.canvas addShape:back];
    back.animationDuration = 0.9f;
    timerDoneSound = [C4Sample sampleNamed:@"timerDone.wav"];
    timerDoneSound.loops = NO;
    [self setupTimer];
    timer = [C4Timer timerWithInterval:1.0f
                                target:self
                                method:@"countDown"
                               repeats:YES];
    [timer stop];
}
-(void) setupTimer {
    [self setupTimerButtons];
    [self setupTimerDisplay];
}
-(void) setupTimerDisplay {
    C4Font *f = [C4Font fontWithName:@"Helvetica" size:45];
    minutes = [C4Label labelWithText:@"00" font:f];
    seconds = [C4Label labelWithText:@"00" font:f];
    C4Label *colon = [C4Label labelWithText:@":" font:f];
    CGPoint centerPoint = self.canvas.center;
    centerPoint.x -=1;
    colon.center = centerPoint;
    centerPoint.x -= 34;
    minutes.center = centerPoint;
    centerPoint.x += 70;
    seconds.center = centerPoint;
    [self.canvas addObjects:@[minutes, seconds, colon]];
}
-(void) setupTimerButtons {
    CGPoint centerPoint = self.canvas.center;
    centerPoint.y -= 50;
    centerPoint.x -= 35;
    minUp = [self upButtonAt:centerPoint];
    centerPoint.y += 100;
    minDown = [self downButtonAt:centerPoint];
    centerPoint.x += 70;
    secDown = [self downButtonAt:centerPoint];
    centerPoint.y -= 100;
    secUp = [self upButtonAt:centerPoint];
    centerPoint = self.canvas.center;
    centerPoint.y += 100;
    C4Shape *startStop = [C4Shape ellipse:CGRectMake(0, 0, 40, 40)];
    startStop.lineWidth = 4.0f;
    startStop.fillColor = [UIColor whiteColor];
    startStop.center = centerPoint;
    centerPoint.y += 50;
    C4Shape *resetButton = [self downButtonAt:centerPoint];
    resetButton.fillColor = [UIColor clearColor];
    resetButton.strokeColor = C4GREY;
    [self listenFor:@"touchesBegan" fromObject:resetButton andRunMethod:@"resetButton"];
    [self listenFor:@"touchesBegan" fromObject:startStop andRunMethod:@"timerButton"];
    [self listenFor:@"touchesBegan" fromObject:minUp andRunMethod:@"minUpTouch"];
    [self listenFor:@"touchesBegan" fromObject:minDown andRunMethod:@"minDownTouch"];
    [self listenFor:@"touchesBegan" fromObject:secUp andRunMethod:@"secUpTouch"];
    [self listenFor:@"touchesBegan" fromObject:secDown andRunMethod:@"secDownTouch"];
    [self.canvas addObjects:@[minUp, minDown, secUp, secDown, startStop, resetButton]];
}
-(void) timerButton {
    if (timerLength > 0){
        if (!timer.isValid) {
            [timer start];
            storedTime = timerLength;
        }
        else {
            [timer stop];
        }
    }
}
-(void) countDown {
    if (timerLength >= 1) {
        timerLength -= 1;
        if (timerLength == 0) {
            back.strokeColor = C4RED;
            [back ellipse:back.frame];
            backIsBlue = NO;
            [timer stop];
            [self timerFinished];
        }
        else {
            if (!backIsBlue) [back rect:back.frame];
            else back.rotation += PI/2;
            back.strokeColor = C4BLUE;
            backIsBlue = YES;
        }
    }
    [self updateTimerDisplay];
}
-(void) timerFinished {
    [timerDoneSound play];
}
-(void) resetButton {
    if (timer.isValid) [timer stop];
    if (backIsBlue) [back ellipse:back.frame];
    timerLength = storedTime;
    [self updateTimerDisplay];
    back.strokeColor = C4BLUE;
    backIsBlue = NO;
}
-(void)minUpTouch {
    timerLength += 60;
    [self updateTimerDisplay];
}
-(void)minDownTouch {
    if (timerLength >= 60) timerLength -= 60;
    [self updateTimerDisplay];
}
-(void)secUpTouch {
    timerLength += 1;
    [self updateTimerDisplay];
}
-(void)secDownTouch {
    if (timerLength >= 1) timerLength -= 1;
    [self updateTimerDisplay];
}
-(void) updateTimerDisplay {
    CGPoint centerPoint = seconds.center;
    if (timerLength%60 >= 10) {
        seconds.text = [NSString stringWithFormat:@"%i", (int)(timerLength%60)]; }
    else {
        seconds.text = [NSString stringWithFormat:@"0%i", (int)(timerLength%60)]; }
    [seconds sizeToFit];
    seconds.center = centerPoint;
    centerPoint = minutes.center;
    if (timerLength/60 >= 10) {
        minutes.text = [NSString stringWithFormat:@"%i", (int)(timerLength/60)]; }
    else {
        minutes.text = [NSString stringWithFormat:@"0%i", (int)(timerLength/60)]; }
    [minutes sizeToFit];
    minutes.center = centerPoint;
}
-(C4Shape *)downButtonAt: (CGPoint)center {
    CGPoint points[3] = {
        CGPointMake(-18, -15),
        CGPointMake(18, -15),
        CGPointMake(0, 15)};
    C4Shape *shape = [C4Shape triangle:points];
    shape.lineWidth = 4.0f;
    shape.fillColor = [UIColor whiteColor];
    shape.center = center;
    return shape;
}
-(C4Shape *)upButtonAt: (CGPoint)center {
    C4Shape *shape = [self downButtonAt:center];
    shape.rotation = PI;
    return shape;
}
@end