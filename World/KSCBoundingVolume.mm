//
//  KSCBoundingVolume.mm
//  World
//
//  Created by Keith Staines on 09/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSCBoundingVolume.h"
#import "KSMMaths.h"

@implementation KSCBoundingVolume


@synthesize area;
@synthesize volume;
@synthesize radius;


////////////////////////////////////////////////////////////////////////////////
// setRadius
// sets the radius and recalculates the volume and surface area
-(void)setRadius:(double)r
{
    radius = r;
    area   = FOURPI * r * r;
    volume = FOURPIBY3 * r * r * r;
}

////////////////////////////////////////////////////////////////////////////////
// radius
// Returns the radius of the bounding sphere
-(double)radius
{ return radius; }

////////////////////////////////////////////////////////////////////////////////
// setCentre
-(void)setCentre:(const KSMVector4 &)theCentre
{
    centre = theCentre;
}

////////////////////////////////////////////////////////////////////////////////
// centre
-(const KSMVector4&)centre
{
    return centre;
}

////////////////////////////////////////////////////////////////////////////////
// init
// Override designated contructor of super
-(id)init
{
    KSMVector4 c = KSMVector4(0.0, 0.0, 0.0, 1.0);
    return [self initWithCentre:c radius:1.0];
}

////////////////////////////////////////////////////////////////////////////////
// initWithCentre:radius
// Designated constructor
-(id)initWithCentre:(const KSMVector4&)atPosition radius:(double)r
{
    self = [super init];
    if(self)
    {
        [self setCentre:atPosition];
        [self setRadius:r];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////
// boundingVolumeWithCentre:radius
// Convenience constructor
+(id)boundingVolumeWithCentre:(const KSMVector4&)atPosition 
                       radius:(double)r;
{
    id bv = [[[self class] alloc] initWithCentre:atPosition radius:r];
    return bv;
}

////////////////////////////////////////////////////////////////////////////////
// )boundingVolumeFromVolume1:volume2
+(id)boundingVolumeFromVolume1:(KSCBoundingVolume*)volume1 
                       volume2:(KSCBoundingVolume*)volume2
{
    KSCBoundingVolume* large;
    KSCBoundingVolume* small;
    if (volume1.radius > volume2.radius) 
    {
        large = volume1;
        small = volume2;
    }
    else
    {
        large = volume2;
        small = volume1;
    }

    //line connecting the centre of the larger sphere to the smaller is...
    KSMVector4 lineLCToSC = ([small centre] - [large centre]);
    if ( fequalzero( lineLCToSC.length2() ) ) 
    {
        // centres are at effectively the same place, so just choose the
        // larger sphere
        return [KSCBoundingVolume boundingVolumeWithCentre:[large centre] 
                                                    radius:[large radius]];
    }
    
    // distance from the furthest edge of larger to the mid point of the line
    // connecting that point to the furthest edge of the smaller is...
    double edgeToMid = 0.5 *(lineLCToSC.length() + [small radius] + [large radius]);
 
    // test to see if the larger sphere completely contains the smaller...
    if (2*[large radius] > edgeToMid + [small radius]) 
    {
        // yes it does, therefore we just construct a bounding volume
        // equal to the larger sphere
        return [KSCBoundingVolume boundingVolumeWithCentre:[large centre] 
                                                    radius:[large radius]];
    }
    
    // length of line connecting the centre of the larger to the mid point is...
    double lineToMid = edgeToMid - [large radius];
    
    // position of this mid point (and so the centre of the desired bounding
    // sphere is
    KSMVector4 centre = [large centre] + lineToMid * lineLCToSC.unitVector();
    
    return [KSCBoundingVolume boundingVolumeWithCentre:centre 
                                                radius:edgeToMid];
}

////////////////////////////////////////////////////////////////////////////////
// overlaps
// Returns true if there is an overlap between this bounding volume and that of
// the specified object
-(BOOL)overlaps:(KSCBoundingVolume*)other
{
    // calculate the square of the distance between centres
    double d2 = (centre - other.centre).length2();

    // they overlap if d2 is less than the square of the sum of their radii
    double radiusSum = radius + other.radius;
    
    return d2 <  (radiusSum * radiusSum) ? YES : NO;

}



@end
