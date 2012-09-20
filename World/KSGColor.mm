//
//  KSGColor.mm
//  World
//
//  Created by Keith Staines on 09/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSGColor.h"

@implementation KSGColorFactory

+ (KSGColor)makeColorWithRed:(float)redAmount 
                 green:(float)greenAmount 
                  blue:(float)blueAmount 
                 alpha:(float)alphaAmount
{

    KSGColor aColor;
    aColor.red   = redAmount;
    aColor.green = greenAmount;
    aColor.blue  = blueAmount;
    aColor.alpha = alphaAmount;
    
    return aColor;
}

+(KSGColor)brightenColor:(KSGColor&)color byFactor:(float)factor
{
    KSGColor brightened;
    brightened.red   = factor * color.red;
    brightened.blue  = factor * color.green;
    brightened.green = factor * color.blue;
    return brightened;
}

+(KSGColor)sumColor:(const KSGColor&)colorA otherColor:(const KSGColor&)colorB
{
    KSGColor sum;
    sum.red   = colorA.red   + colorB.red;
    sum.green = colorA.green + colorB.green;
    sum.blue  = colorA.blue  + colorB.blue;
    sum.alpha = colorA.alpha;
    return sum;
}

+(KSGColor)scalarProductOfColor:(const KSGColor&)colorA 
                      withColor:(const KSGColor&)colorB
{
    KSGColor product;
    product.red   = colorA.red   * colorB.red;
    product.green = colorA.green * colorB.green;
    product.blue  = colorA.blue  * colorB.blue;
    product.alpha = colorA.alpha * colorB.alpha;
    return product;
}

+(void)colorWithName:(NSString*)colorName 
    fromListWithName:(NSString*)listName 
               color:(KSGColor&)color 
     colorWasCreated:(BOOL*)result
{    
    NSColorList * list = [NSColorList colorListNamed:listName];
    if (!list) 
    {
        *result = NO;
        return;
    }
    
    NSColor * nsColor = [list colorWithKey:colorName];
    if (!nsColor) 
    {
        *result = NO;
        return;
    }
    // found a color of the requested name so copy its data to the KSGColor struct
    color.red   = [nsColor redComponent];
    color.green = [nsColor greenComponent];
    color.blue  = [nsColor blueComponent];
    color.alpha = [nsColor alphaComponent];
    
    // state that we found the color
    *result = YES;
    return;
}

+(KSGColor)makeColor:(NSString *)colorName
{
    BOOL result = NO;
    NSString * colorListName;
    KSGColor color = [KSGColorFactory makeColorWithRed:0 
                                                 green:0 
                                                  blue:0 
                                                 alpha:1];
    
    // Try Apple's basic color list first
    colorListName = @"Apple";
    [self colorWithName:colorName 
       fromListWithName:colorListName 
                  color:color 
        colorWasCreated:&result];
    
    if (result) 
    {
        return color;
    }
    
    //
    
    // Try Apple's more extensive crayon colors list
    colorListName = @"Crayons";
    [self colorWithName:colorName 
       fromListWithName:colorListName 
                  color:color 
        colorWasCreated:&result];

    // return the result which will either be the requested color or black
    // if not found
    return color;
}

@end
