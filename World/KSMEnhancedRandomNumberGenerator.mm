//
//  KSMEnhancedRandomNumberGenerator.mm
//  World
//
//  Created by Keith Staines on 07/01/2012.
//  Copyright (c) 2012 Object Computing Solutions LTD. All rights reserved.
//

#import "KSMEnhancedRandomNumberGenerator.h"

@implementation KSMEnhancedRandomNumberGenerator

-(id)init
{
    // defaults to the smallest footprint configuration
    return [self initWithSeed:1 stateSize:8];
}

-(id)initWithSeed:(NSInteger)seedValue stateSize:(uint)size;
{
    self = [super init];
    uint seed = (uint)( seedValue % UINT32_MAX );
    _max = pow(2, 31) - 1;
    _state = new char[size];
    initstate(seed, _state, size);
    return self;
}

-(NSUInteger)nextRandom
{
    char * oldState = setstate(_state);
    long r = random();
    setstate(oldState);
    return r;
}

-(void)dealloc
{
    delete [] _state;
}
@end
