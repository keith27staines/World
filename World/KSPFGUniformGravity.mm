//
//  KSPFGUniformGravity.mm
//  World
//
//  Created by Keith Staines on 06/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSPFGUniformGravity.h"
#import "KSPConstants.h"


@implementation KSPFGUniformGravity

@synthesize accelerationDueToGravity;

-(id)init
{
    self = [super init];
    accelerationDueToGravity = kspc1G;
    return self;
}

-(KSMVector3)forceOnBody:(KSPPhysicsBody*)body overInterval:(double)dt
{
    return KSMVector3(0, -accelerationDueToGravity * body.mass, 0);
}

@end
