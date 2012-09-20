//
//  KSESolarSystem.mm
//  World
//
//  Created by Keith Staines on 04/01/2012.
//  Copyright (c) 2012 Object Computing Solutions LTD. All rights reserved.
//

#import "KSESolarSystem.h"
#import "KSESolarSystemBody.h"
#import "KSPMomentsOfInertia.h"

@interface KSESolarSystem ()
KSMVector3 angularVelocity(double rotationperiod, double tilt);
double gravStrength(double period, double radius);
double orbitalSpeed(double gravStrength, double radius);
KSMVector3 orbitalVelocity(double gravStrength, double radius, double inclination);

@end


KSMVector3 angularVelocity(double rotationperiod, double tilt)
{
    // unit vector in direction of tilt
    KSMVector3 direction = KSMVector3(1.0, 1.0 / tan(tilt),0.0);
    direction.normalise();
    
    KSMVector3 angVel = (TWOPI / rotationperiod) * direction;
    return angVel;
}

// gravitational strength represents GM in physically realistic units
double gravStrength(double period, double radius)
{
    return (TWOPI * TWOPI / period) * radius * radius * radius;
}

double orbitalSpeed(double gravStrength, double radius)
{
    double speed = sqrt(gravStrength / radius);
    return speed;
}

KSMVector3 orbitalVelocity(double gravStrength, double radius, double inclination)
{
    double speed = orbitalSpeed(gravStrength, radius);
    double vy = cos(inclination) * speed;
    double vx = sin(inclination) * speed;
    
    
    return KSMVector3();
    
}

@implementation KSESolarSystem

-(id)init
{
    NSUInteger nBodies = 9;
    systemBodies = [NSMutableDictionary dictionaryWithCapacity:nBodies];
    self = [super init];
    KSESolarSystemBody * body;
    const double systemRadius        = 1.0E6;
    const double systemMassScale     = 1.0E12;
    const double RE                  = systemRadius * 1.0E-6; 
    const double AU                  = systemRadius * 0.1;
    const double YEAR                = 5.0 * 60.0; // actually, five minutes
    const double DAY                 = YEAR / 365.0;
    
    // The radii of the bodies in the system. Note that the relative proportions reflect reality, although "RE" may not.
    const double bodyRadius[] = 
    {
        100.0 * RE,     // sun
          0.4 * RE,     // mercury
          1.0 * RE,     // venus
          1.0 * RE,     // earth
          0.5 * RE,     // mars
         11.0 * RE,     // jupiter
          9.0 * RE,     // saturn
          4.0 * RE,     // uranus
          3.8 * RE      // neptune
    };
    
    // The orbital radii of the system bodies. Note that the relative proportions reflect reality, although "AU" may not.
    const double orbitalRadius[] =
    {
         0.0,            // sun
         0.4 * AU,       // mercury
         0.7 * AU,       // venus
         1.0 * AU,       // earth
         1.5 * AU,       // mars
         5.2 * AU,       // jupiter
         9.5 * AU,       // saturn
        19.2 * AU,       // uranus
        30.0 * AU        // neptune 
    };
    
    // The eccentricity of the orbits. These numbers reflect reality
    const double orbitalEccentricity[] =
    {
        0.0,       // sun
        0.2,       // mercury
        0.0,       // venus
        0.0,       // earth
        0.0,       // mars
        0.0,       // jupiter
        0.0,       // saturn
        0.0,       // uranus
        0.0,       // neptune        
    };
    
    // The inclinations of the orbits. These numbers reflect reality.
    const double orbitalInclination[] =
    {
        degTorad(0.0),       // sun
        degTorad(7.0),       // mercury
        degTorad(3.4),       // venus
        degTorad(0.0),       // earth
        degTorad(1.9),       // mars
        degTorad(1.3),       // jupiter
        degTorad(2.5),       // saturn
        degTorad(0.8),       // uranus
        degTorad(1.8),       // neptune  
    };

    const double axialTilt[] =
    {
        degTorad(0.0),       // sun
        degTorad(2.0),       // mercury
        degTorad(177.0),     // venus
        degTorad(23.5),      // earth
        degTorad(25.2),      // mars
        degTorad(3.1),       // jupiter
        degTorad(26.7),      // saturn
        degTorad(97.9),      // uranus
        degTorad(29.6),      // neptune         
    };
    
    const double rotationPeriod[] =
    {
        1.0 * DAY,       // sun
        1.0 * DAY,       // mercury
        1.0 * DAY,       // venus
        1.0 * DAY,       // earth
        1.0 * DAY,       // mars
        1.0 * DAY,       // jupiter
        1.0 * DAY,       // saturn
        1.0 * DAY,       // uranus
        1.0 * DAY,       // neptune          
    };
    
    
    

    // make the sun
    body = [KSESolarSystemBody alloc];
    body = [body initWithName:@"sun" 
                         type:@"star (G class)" 
                 nameOfParent:nil 
                         mass:systemMassScale
                       radius:100.0 * RE
             relativePosition:KSMVector3() 
             relativeVelocity:KSMVector3() 
              angularVelocity:KSMVector3()];
    [systemBodies setObject:body forKey:[body name]];
    
    // make mercury
    body = [KSESolarSystemBody alloc];
    body = [body initWithName:@"mercury" 
                         type:@"planet (terrestrial)" 
                 nameOfParent:@"sun" 
                         mass:systemMassScale / 1.0E6 
                       radius:0.25 * RE 
             relativePosition:KSMVector3()  
             relativeVelocity:KSMVector3()  
              angularVelocity:KSMVector3() ];
    
    return self;
}
@end
