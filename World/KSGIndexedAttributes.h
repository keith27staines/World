//
//  KSGIndexedAttributes.h
//  World
//
//  Created by Keith Staines on 07/09/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

enum KSGL_SHADER_ATTRIBUTE 
{
    KSGL_SHADER_ATTRIBUTE_VERTEX = 0,
    KSGL_SHADER_ATTRIBUTE_COLOR,
    KSGL_SHADER_ATTRIBUTE_NORMAL,
    KSGL_SHADER_ATTRIBUTE_TEXTURE0,
    KSGL_SHADER_ATTRIBUTE_TEXTURE1,
    KSGL_SHADER_ATTRIBUTE_TEXTURE2,
    KSGL_SHADER_ATTRIBUTE_TEXTURE3,
};

////////////////////////////////////////////////////////////////
// Class KSGIndexedAttribute 
@interface KSGIndexedAttribute : NSObject 
{
    @private int indexForAttrbute;
    @private NSString* attribute;
}

@property (readonly) int indexForAttrbute;
@property (copy, readonly) NSString* attribute;

-(id) initWithIndex:(int)index
          Attribute:(NSString*) attribute;

-(void)setIndex:(int)index Attribute:(NSString *)attr;

@end


////////////////////////////////////////////////////////////////
// Class KSGIndexedAttributes (wraps an NSArray)
@interface KSGIndexedAttributes : NSObject
{

}
@property (strong, readonly) NSMutableArray* indexedAttributes;

-(void) addIndex:(int)index
        AndValue:(NSString*) value;

-(void) setToFullDefaults;

@end
