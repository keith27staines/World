//
//  KSPFGAnchoredSpring.mm
//  World
//
//  Created by Keith Staines on 06/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSPFGAnchoredSpring.h"

@implementation KSPFGAnchoredSpring
@synthesize physicsBody;


-(void)setBodyAttachPointMC:(KSMVector4&)attachPoint
{
    bodyAttachPointMC = attachPoint;
}

-(KSMVector4&)bodyAttachPointMC
{
    return bodyAttachPointMC;
}

-(void)setWorldAnchorPointWC:(KSMVector3&)anchor        
{
    worldAnchorPointWC = anchor;
}

-(KSMVector3 &)worldAnchorPointWC
{
    return worldAnchorPointWC;
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
               physicsBody:(KSPPhysicsBody*)body 
         bodyAttachPointMC:(KSMVector4&)attachPointMC 
        worldAnchorPointWC:(KSMVector3&)anchorWC
{
    self = [super initWithNaturalLength:length
                         springConstant:spring 
                        dampingConstant:damping
                               isBungee:bungee];
    
    [self setPhysicsBody:body];
    [self setBodyAttachPointMC:attachPointMC];
    [self setWorldAnchorPointWC:anchorWC];
    
    return self;
}

-(void)applyForce
{
    // get the body to world transform
    KSMMatrix4 modelWorld = [physicsBody modelWorld];
    
    // get the attach point in world coordinates
    KSMVector3 attachPointWC = (modelWorld * bodyAttachPointMC).vector3();
    
    // get the vector in direction of the body from the anchor point
    KSMVector3 s = (attachPointWC - worldAnchorPointWC);
    
    // calculate the extension of the spring
    double extension = s.length() - naturalLength;
    
    if ( isBungee && extension <=0 ) 
    {
        // slack string, hence no force
        return;
    }
    
    // convert s to unit vector
    KSMVector3 sUnit = s.unitVector();
    
    // calculate spring force
    KSMVector3 springForce = (- extension * springConstant) * sUnit;
    
    // do we also need to consider damping?
    if (dampingConstant > 0)
    {
        // the damping force depends on the rate of change of the length 
        // of the spring
        KSMVector3 velocityWC = [physicsBody velocityWCOfBodyPositionMC:
                                                             bodyAttachPointMC];
        double rate = velocityWC * sUnit;        
        springForce -= (dampingConstant * rate) * sUnit;
    }

    // apply the force to the body at the attach point
    [physicsBody addForce:springForce atWorldPosition:attachPointWC];
    return;
    
}

// must override the mass
-(double)mass
{
    return physicsBody.mass;
}
@end
