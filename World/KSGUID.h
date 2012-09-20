//
//  KSGUID.h
//  World
//
//  Created by Keith Staines on 18/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSGUID : NSObject
{
    NSUInteger uid;
}

+(NSString*)concatenateNameOfObject:(KSGUID*)objectA 
                         withObject:(KSGUID*) objectB;

+(NSUInteger)reserveNextUnassignedNumber;

+(BOOL)firstUID:(KSGUID*)firstUID sameAs:(KSGUID*)secondUID;

-(BOOL)isEqualTo:(KSGUID*)object;
-(BOOL)isNotEqualTo:(KSGUID*)object;
-(BOOL)isLessThan:(KSGUID*)object;
-(BOOL)isGreaterThan:(KSGUID*)object;
-(NSString*)name;

                    
@end
