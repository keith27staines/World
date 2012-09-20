//
//  KSMRandomNumberGeneratorCMWC.mm
//  RandomNumbers
//
//  Created by Keith Staines on 07/01/2012.
//  Copyright (c) 2012 Object Computing Solutions LTD. All rights reserved.
//

#import "KSMRandomNumberGeneratorCMWC.h"

@implementation KSMRandomNumberGeneratorCMWC
const uint64_t a = 18782LL;
const uint32_t r   = 0xfffffffe;
const uint32_t PHI = 0x9e3779b9;

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
    // we actually use the seed to generate another 4096 seeds...
    for (int j = 0; j < 4096; j++) 
    {
        q[j] = rand();
    }
}

-(id)init
{
    // defaults to a non-reproducible sequence
    return [self initWithSeed:-1];
}

-(id)initWithSeed:(NSInteger)seedValue;
{
    self = [super init];
    _max = UINT32_MAX;
    c = 362436; 
    i = 4095;
    [self seed:(int32_t)(seedValue % INT32_MAX)];
    return self;
}

-(NSUInteger)nextRandom
{
    i = (i + 1) & 4095;
    uint64_t  t = a * q[i] + c;
    c = (t >> 32);
    uint32_t x = (uint32_t)(t + c);
    if (x < c )
    {
        x++;
        c++;
    }
    return ( q[i] = r - x );
}
@end
