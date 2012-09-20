//
//  KSGUID.mm
//  World
//
//  Created by Keith Staines on 18/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSGUID.h"
static NSUInteger nextUid = 0;

@implementation KSGUID

+(BOOL)firstUID:(KSGUID*)firstUID sameAs:(KSGUID*)secondUID
{
    return [firstUID isEqualTo:secondUID];
}

+(NSUInteger)reserveNextUnassignedNumber
{
    return nextUid++;
}

-(NSUInteger)numericValue
{
    return uid;
}

-(id)init
{
    self = [super init];
    if (self) 
    {
        uid = [KSGUID reserveNextUnassignedNumber];
    }
    return self;
}

-(BOOL)isEqualTo:(KSGUID *)object
{
    return (uid == [object numericValue]);
}

-(BOOL)isNotEqualTo:(KSGUID *)object
{
    return !([self isEqualTo:object]);
}

-(BOOL)isLessThan:(KSGUID *)object
{
    NSUInteger otherUID = [object numericValue];
    
    return (uid < otherUID);
}

-(BOOL) isGreaterThan:(KSGUID *)object
{
    return ![self isLessThan:object];
}

-(NSString*)name
{
    return [NSString stringWithFormat:@"%09i",uid];
}

+(NSString*)concatenateNameOfObject:(KSGUID*)objectA 
                         withObject:(KSGUID*)objectB
{
    NSMutableString* concatenated = [NSMutableString string];
    NSString * divider = @":";
    if ([objectA isLessThan:objectB]) 
    {
        [concatenated appendString:[objectA name]];
        [concatenated appendString:divider];
        [concatenated appendString:[objectB name]];
    }
    else
    {
        [concatenated appendString:[objectB name]];
        [concatenated appendString:divider];
        [concatenated appendString:[objectA name]];        
    }
    
    return concatenated;
}

@end
