//
//  KSCPrimitiveBox.h
//  World
//
//  Created by Keith Staines on 03/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSCPrimitive.h"
#import "KSMMaths.h"

@interface KSCPrimitiveBox : KSCPrimitive
{
    KSMVector3 _halfSize;
}

@property (assign) const KSMVector3 & halfSize;

@end
