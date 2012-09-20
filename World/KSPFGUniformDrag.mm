//
//  KSPFGUniformDrag.mm
//  World
//
//  Created by Keith Staines on 29/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSPFGUniformDrag.h"
#import "KSCBoundingVolume.h"

@implementation KSPFGUniformDrag
@synthesize linearDragCoefficient    = _linearDragCoefficient;
@synthesize quadraticDragCoefficient = _quadraticDragCoefficient;

+(id)makeStillAirResistance
{
    KSPFGUniformDrag * dragFG = [[self alloc] init];
    dragFG.linearDragCoefficient    = 1.7E-3;  // "official" value = 1.7E-4
    dragFG.quadraticDragCoefficient = 0.2;     // "official" value = 0.2
    return dragFG;
}

+(id)makeStillWaterResistance
{
    KSPFGUniformDrag * dragFG = [[self alloc] init];
    dragFG.linearDragCoefficient    = 9.4E-3;  // "official" value = 9.4E-3
    dragFG.quadraticDragCoefficient = 156;     // "official" value = 156
    return dragFG;
}

-(id)init
{
    self = [super init];
    self.linearDragCoefficient    = 0;
    self.quadraticDragCoefficient = 0;
    return self;
}

-(void)scaleFactorsBy:(double)factor
{
    _linearDragCoefficient    *= factor;
    _quadraticDragCoefficient *= factor;
}

-(KSMVector3)forceOnBody:(KSPPhysicsBody*)body overInterval:(double)dt
{
    double radius = [body characteristicLinearDimension]; 
    KSMVector3 velocity = [body linearVelocity];
    double speed = velocity.length();
    KSMVector3 dir = velocity.unitVector();
    dir.reverse();
    double magnitude = radius * (_linearDragCoefficient * speed + 
                _quadraticDragCoefficient *  speed * speed);
    
    double maxMagnitude = 0.05 * speed * body.mass / dt;
    magnitude = fmin(magnitude, maxMagnitude);
    return magnitude * dir;
}
@end
