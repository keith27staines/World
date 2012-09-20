//
//  NormalDistributionFunction.m
//  KSMRandomNumbers
//
//  Created by Keith Staines on 06/01/2012.
//  Copyright (c) 2012 Object Computing Solutions LTD. All rights reserved.
//

#import "KSMNormalDistributionFunction.h"
#import "KSMRandomNumberGenerator.h"

@implementation KSMNormalDistributionFunction

-(id)init
{
    KSMRandomNumberGenerator * rgen = [KSMRandomNumberGenerator alloc];
    rgen = [rgen initWithSeed:1];
    return [self initWithMeanValue:0 standardDeviation:1 randomGenerator:rgen];
}

 -(id)initWithMeanValue:(double)mean 
      standardDeviation:(double)sigma
        randomGenerator:(KSMRandomNumberGenerator *)rgen
{
    self = [super init];
    _mean = mean;
    _standardDeviation = sigma;
    _generator = rgen;

    double twoSigmaSquared = 2.0 * sigma * sigma;
    double A = 1.0 / sqrt(twoSigmaSquared * pi ); 
    _probabilityDensity = ^(double x)
    {
        return A * exp( - (x - mean) * (x - mean) /twoSigmaSquared );
    };
    
    return self;
}
 
-(double)nextRandomSample
{
    // Random-walk type argument using the central limit theorem.
    // Good for deviates in the range +/-6 standard deviations
    double r;
    for (int i = 0; i < 12; i++) 
    {
        r += [_generator nextRandomDoubleFrom:-1 to:1];
    }
    return _mean + _standardDeviation * (r - 6.0);
}

@end
