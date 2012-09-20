//
//  KSMDistributionFunctionAbstractBase.h
//  RandomNumbers
//
//  Created by Keith Staines on 07/01/2012.
//  Copyright (c) 2012 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMRandomNumberGenerator.h"

// Define a block that will evaluate the probability density at the specified
// value of the random variable.
typedef double(^probabilityDensityFunction)(double randomVariable);

@interface KSMDistributionFunctionAbstractBase : NSObject
{
    // minimum value of the random variable
    double _xMin;
    
    // maximum value of the random variable
    double _xMax;
    
    // mean value of the random variable
    double _mean;
    
    // standard deviation of the probability density function
    double _standardDeviation;
    
    // maximum value of the probability density function
    double _yMax;
    
    // normalising factor (multiply the density function by this factor to
    // get the normalised density;
    double _normalisation;
    
    // random number generator used to sample values from the distribution
    KSMRandomNumberGenerator * _generator;
    
    // the probability density function
    probabilityDensityFunction _probabilityDensity;
    
}

@property double xMin;
@property double xMax;
@property (readonly) double yMax;
@property (readonly) double mean;
@property (readonly) double standardDeviation;
@property (strong) KSMRandomNumberGenerator * generator;

-(void)analyse;
-(double)nextRandomSample;
-(double)probabilityDensity:(double)randomVariable;

@end
