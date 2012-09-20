//
//  KSGManagedResourceBase.mm
//  World
//
//  Created by Keith Staines on 04/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSGManagedResourceBase.h"

const NSString* UNSPECIFIED_NAME = @"UNSPECIFIED NAME";


@implementation KSGManagedResourceBase

@synthesize isOpen;
@synthesize name;

////////////////////////////////////////////////////////////////////////////////
// init
// Override designated constructor of super
-(id)init
{
    // redirect to the new designated constructor
    return [self initWithName:nil];
}

////////////////////////////////////////////////////////////////////////////////
// initWithName
// Designated constructor (Sub classes should override this)
-(id)initWithName:(NSString *)aName
{
    self = [super init];
    if (self) {
        isOpen = YES;
        
        if (!aName) {
            aName = [UNSPECIFIED_NAME copy];
        }
        
        name = aName;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////
// resourceWithName
+(id)resourceWithName:(NSString*)aName
{
    return [[[self class]alloc] initWithName:aName];
}

@end
