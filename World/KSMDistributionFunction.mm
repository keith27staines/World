//
//  KSMDistributionFunction.m
//  RandomNumbers
//
//  Created by Keith Staines on 06/01/2012.
//  Copyright (c) 2012 Object Computing Solutions LTD. All rights reserved.
//

#import "KSMDistributionFunction.h"

@implementation KSMDistributionFunction


-(id)initWithMimimumX:(double)xMin 
             maximumX:(double)xMax 
      densityFunction:(probabilityDensityFunction)f 
      randomGenerator:(KSMRandomNumberGenerator *)rgen
{
    //self = [super init];
    _xMin = xMin;
    _xMax = xMax;
    _generator = rgen;
    _probabilityDensity = f;
    [self analyse];
    return self;
}


@end
