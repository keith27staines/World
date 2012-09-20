//
//  KSGIndexedAttributes.m
//  World
//
//  Created by Keith Staines on 07/09/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSGIndexedAttributes.h"

////////////////////////////////////////////////////////////////////////////////
// Class KSGIndexedAttribute 
@implementation KSGIndexedAttribute

@synthesize indexForAttrbute;
@synthesize attribute;

- (id)init
{
    return [self initWithIndex:0 Attribute:nil];
}

-(id)initWithIndex:(int)index Attribute:(NSString *)attr
{
    self = [super init];
    if (self) {
        [self setIndex: index Attribute:attr];
    }
    
    return self;    
}

-(void)setIndex:(int)index Attribute:(NSString *)attr
{
    indexForAttrbute = index;
    attribute = attr;    
}


@end


////////////////////////////////////////////////////////////////////////////////
// Class KSGIndexedAttributes (wraps an NSArray)
@implementation KSGIndexedAttributes
@synthesize indexedAttributes;

- (id)init
{
    self = [super init];
    if (self) {
         indexedAttributes = [[NSMutableArray alloc] initWithCapacity:16];
    }
    
    return self;
}

-(void) addIndex:(int)index
        AndValue:(NSString*) value
{
    KSGIndexedAttribute *ia = [[KSGIndexedAttribute alloc] initWithIndex:index
                                                               Attribute:value];
    [[self indexedAttributes] addObject:ia];
}
     
-(void)setToFullDefaults
{
    [self addIndex:KSGL_SHADER_ATTRIBUTE_VERTEX   AndValue:@"v4VertexMC"];
    [self addIndex:KSGL_SHADER_ATTRIBUTE_COLOR    AndValue:@"v4Color"];
    [self addIndex:KSGL_SHADER_ATTRIBUTE_NORMAL   AndValue:@"v3NormalMC"];
    [self addIndex:KSGL_SHADER_ATTRIBUTE_TEXTURE0 AndValue:@"v2Texture0"];
    [self addIndex:KSGL_SHADER_ATTRIBUTE_TEXTURE1 AndValue:@"v2Texture1"];
    [self addIndex:KSGL_SHADER_ATTRIBUTE_TEXTURE2 AndValue:@"v2Texture2"];
    [self addIndex:KSGL_SHADER_ATTRIBUTE_TEXTURE3 AndValue:@"v2Texture3"];
}


@end
