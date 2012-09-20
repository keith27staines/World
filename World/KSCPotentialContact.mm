//
//  KSCPotentialContact.mm
//  World
//
//  Created by Keith Staines on 10/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSCPotentialContact.h"
#import "KSGUID.h"

@implementation KSCPotentialContact
@synthesize bodyA;
@synthesize bodyB;
@synthesize name;


// override designated constructor of super
-(id)init
{
    return [self initWithBodyA:nil bodyB:nil];
}

-(id)initWithBodyA:(NSObject<KSCBody>*)aBodyA 
             bodyB:(NSObject<KSCBody>*)aBodyB
{
    self = [super init];
    if (self) 
    {
        bodyA = aBodyA;
        bodyB = aBodyB; 

        name = [KSGUID concatenateNameOfObject:aBodyA.uid withObject:aBodyB.uid]; 
    }
    
    return self;
}

+(id)potentialContactWithBodyA:(NSObject<KSCBody>*)aBodyA 
                         bodyB:(NSObject<KSCBody>*)aBodyB
{
    KSCPotentialContact* contact = [[[self class] alloc] initWithBodyA:aBodyA 
                                                                 bodyB:aBodyB];
    
    return contact;
}

@end
