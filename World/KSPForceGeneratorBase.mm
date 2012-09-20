//
//  KSPForceGeneratorBase.mm
//  World
//
//  Created by Keith Staines on 12/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSPForceGeneratorBase.h"

@implementation KSPForceGeneratorBase
@synthesize name;

- (id)init 
{
    self = [super init];
    if (self) 
    {
        name = [self description];
    }
    return self;
}


-(void)applyForceOverInterval:(double)dt 
{
   // provide null implementation
}

@end
