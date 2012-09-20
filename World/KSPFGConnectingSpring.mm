//
//  KSPFGConnectingSpring.mm
//  World
//
//  Created by Keith Staines on 07/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSPFGConnectingSpring.h"

@implementation KSPFGConnectingSpring
@synthesize physicsBody1;
@synthesize physicsBody2;

-(void)setBody1AttachPointMC:(KSMVector4&)attachPoint
{
    body1AttachPointMC = attachPoint;
}

-(void)setBody2AttachPointMC:(KSMVector4&)attachPoint
{
    body2AttachPointMC = attachPoint;
}

-(KSMVector4 &)body1AttachPointMC
{
    return body1AttachPointMC;
}

-(KSMVector4 &)body2AttachPointMC
{
    return body2AttachPointMC;
}

// override designated constructor of super
-(id)initWithNaturalLength:(double)length 
            springConstant:(double)spring 
           dampingConstant:(double)damping 
                  isBungee:(BOOL)bungee
{
    [self mustOverride];
    return nil;
}

// designated constructor
-(id)initWithNaturalLength:(double)length 
            springConstant:(double)spring
           dampingConstant:(double)damping
                  isBungee:(BOOL)bungee
              physicsBody1:(KSPPhysicsBody*)body1 
        body1AttachPointMC:(KSMVector4&)attachPoint1MC 
              physicsBody2:(KSPPhysicsBody*)body2 
        body2AttachPointMC:(KSMVector4&)attachPoint2MC 
{
    self = [super initWithNaturalLength:length
                         springConstant:spring 
                        dampingConstant:damping 
                               isBungee:bungee];
    
    [self setPhysicsBody1:body1];
    [self setBody1AttachPointMC:attachPoint1MC];
    [self setPhysicsBody2:body2];
    [self setBody2AttachPointMC:attachPoint2MC];
    return self;
}

// override to apply the force due to a spring coupling two bodies together
-(void)applyForce
{
    // get the body to world transforms
    KSMMatrix4 modelWorld1 = [physicsBody1 modelWorld];
    KSMMatrix4 modelWorld2 = [physicsBody2 modelWorld];
    
    // get the attach points in world coordinates
    KSMVector3 attachPoint1WC = (modelWorld1 * body1AttachPointMC).vector3();
    KSMVector3 attachPoint2WC = (modelWorld2 * body2AttachPointMC).vector3();
    
    // get the vector in direction body1 -> body2 
    KSMVector3 s12 = (attachPoint2WC - attachPoint1WC);
    
    // calculate the extension of the spring
    double extension = s12.length() - naturalLength;
    
    if ( isBungee && extension <=0 ) 
    {
        // slack string, hence no force
        return;
    }
    
    // convert s to unit vector
    KSMVector3 s12Unit = s12.unitVector();
    
    // calculate spring force acting on body 2
    KSMVector3 springForce = (- extension * springConstant) * s12Unit;
    
    // do we also need to consider damping?
    if (dampingConstant != 0)
    {
        // the damping force depends on the rate of change of the length 
        // of the spring
        KSMVector3 velocity1WC = [physicsBody1 velocityWCOfBodyPositionMC:
                                                            body1AttachPointMC];
        
        KSMVector3 velocity2WC = [physicsBody2 velocityWCOfBodyPositionMC:
                                                            body2AttachPointMC];
        double rate = (velocity2WC - velocity1WC) * s12Unit;        
        springForce -= (dampingConstant * rate) * s12Unit;
    }
    
    // apply the force body2 at its attach point
    [physicsBody2 addForce:springForce atWorldPosition:attachPoint2WC];
    
    // By equal and opposite reaction, we can apply the spring force to
    // body1...
    springForce.reverse();
    [physicsBody1 addForce:springForce atWorldPosition:attachPoint1WC];
    return;
}

// Must override mass, in this case to return the sum of the two masses
// coupled together by the spring
-(double)mass
{
    return physicsBody1.mass + physicsBody2.mass;
}
@end

