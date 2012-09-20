//
//  KSMDistributionFunctionAbstractBase.mm
//  RandomNumbers
//
//  Created by Keith Staines on 07/01/2012.
//  Copyright (c) 2012 Object Computing Solutions LTD. All rights reserved.
//

#import "KSMDistributionFunctionAbstractBase.h"


@implementation KSMDistributionFunctionAbstractBase
@synthesize xMin = _xMin;
@synthesize xMax = _xMax;
@synthesize yMax = _yMax;
@synthesize mean = _mean;
@synthesize standardDeviation = _standardDeviation;
@synthesize generator = _generator;

-(void)analyse
{
    double x = 0;
    double y = 0;
    double ydx = 0;
    double dx = ( _xMax - _xMin ) / 1000;
    for (int i = 0; i < 1001; i++) 
    {       
        x = _xMin + i * dx;
        y = _probabilityDensity(x);
        ydx = y * dx;
        _normalisation += ydx;
        _mean += x * ydx;
        if (y > _yMax) 
        {
            _yMax = y;
        }
    }
    _normalisation = 1.0 / _normalisation;
    _mean = _mean * _normalisation;
    double meanSquare = 0;
    for (int i = 0; i < 1001; i++) 
    {       
        x = _xMin + i * dx;
        y = _probabilityDensity(x);
        ydx = y*dx;
        meanSquare += (x - _mean) * (x - _mean) * ydx;
    }
    _standardDeviation = sqrt(meanSquare * _normalisation);
}

-(double)nextRandomSample
{
    // basic rejection filter, general purpose, works for anything
    // but can be very slow.
    double x = [_generator nextRandomDoubleFrom:_xMin to:_xMax];
    double y = [_generator nextRandomDoubleFrom:0 to:_yMax];
    if ( y < _probabilityDensity(x) ) return x;
    return [self nextRandomSample];
}

-(double)probabilityDensity:(double)randomVariable
{
    return _probabilityDensity(randomVariable);
}

-(id)init
{
    // This is an abstract base class
    NSAssert(NO, @"You are trying to instantiate an abstract base class");
    return nil;
}
@end
