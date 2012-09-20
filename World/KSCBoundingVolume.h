//
//  KSCBoundingVolume.h
//  World
//
//  Created by Keith Staines on 09/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMMaths.h"

@interface KSCBoundingVolume : NSObject
{
    double       volume;
    double       area;
    KSMVector4   centre;
    double       radius;
    
}

@property (readonly)  double              volume;
@property (readonly)  double              area;
@property (assign)    double              radius;
@property (assign)    const KSMVector4&   centre;

////////////////////////////////////////////////////////////////////////////////
// boundingVolumeWithCentre:radius
// Convenience constructor
+(id)boundingVolumeWithCentre:(const KSMVector4&)atPosition radius:(double)r;

////////////////////////////////////////////////////////////////////////////////
// boundingVolumeFromVolume1:volume2
// Constructs a bounding volume that will bound the two specified volumes
+(id)boundingVolumeFromVolume1:(KSCBoundingVolume*)volume1 
                       volume2:(KSCBoundingVolume*)volume2;

////////////////////////////////////////////////////////////////////////////////
// initWithCentre:radius
// Designated constructor
-(id)initWithCentre:(const KSMVector4&)atPosition radius:(double)r;

////////////////////////////////////////////////////////////////////////////////
// overlaps
// Returns true if there is an overlap between this bounding volume and that of
// the specified object
-(BOOL)overlaps:(KSCBoundingVolume*)other;


@end
