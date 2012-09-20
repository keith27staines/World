//
//  KSMRandomNumberGenerator.mm
//  RandomNumbers
//
//  Created by Keith Staines on 06/01/2012.
//  Copyright (c) 2012 Object Computing Solutions LTD. All rights reserved.
//

#import "KSMRandomNumberGenerator.h"


@implementation KSMRandomNumberGenerator

-(void)seed:(int32_t)value
{
    if (value >= 0) 
    {
        srand(value);
    }
    else if ( value < 0 )
    {
        sranddev();
    }
}

-(id)init
{
    return [self initWithSeed:1];
}

-(id)initWithSeed:(NSInteger)seedValue;
{
    self = [super init];
    _max = RAND_MAX;
    [self seed:(int32_t)(seedValue % INT32_MAX)];
    return self;
}

-(NSUInteger)nextRandom
{
    return rand();
}

-(NSUInteger)largestRandomInteger
{
    return _max;
}

-(NSUInteger)nextRandomIntegerFrom:(NSUInteger)lowest to:(NSUInteger)highest
{
    return lowest + ( [self nextRandom] % (highest - lowest + 1) );
}

-(double)nextRandomDoubleFrom:(double)lowest to:(double)highest
{
    return lowest + (highest - lowest) * [self nextRandom] / (double)_max;
}

@end
