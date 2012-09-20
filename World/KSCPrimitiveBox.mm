//
//  KSCPrimitiveBox.mm
//  World
//
//  Created by Keith Staines on 03/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSCPrimitiveBox.h"

@implementation KSCPrimitiveBox

-(const KSMVector3&)halfSize
{
    return _halfSize;
}

-(void)setHalfSize:(const KSMVector3 &)halfSize
{
    _halfSize = halfSize;
    self.linearSize = halfSize.length();
}
@end
