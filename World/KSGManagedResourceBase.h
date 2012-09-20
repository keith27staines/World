//
//  KSGManagedResourceBase.h
//  World
//
//  Created by Keith Staines on 04/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSGManagedResourceBase : NSObject
{
    @protected
    BOOL        isOpen;
    NSString *  name;
}

@property (assign)  BOOL        isOpen;
@property (copy)    NSString*   name;

+(id)resourceWithName:(NSString*)aName;

-(id)initWithName:(NSString*)aName;

@end
