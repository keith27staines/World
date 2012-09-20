//
//  KSGColor.h
//  World
//
//  Created by Keith Staines on 09/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

union KSGColor 
{
    union 
    {
        struct
        {
            float red;
            float green;
            float blue;
            float alpha;
        };        
        float f[4];
    };
};

@interface KSGColorFactory : NSObject
{

}

+ (KSGColor)makeColorWithRed:(float)redAmount 
                       green:(float)greenAmount 
                        blue:(float)blueAmount 
                       alpha:(float)alphaAmount;

+(KSGColor)brightenColor:(KSGColor&)color byFactor:(float)factor;

+(KSGColor)sumColor:(const KSGColor&)colorA otherColor:(const KSGColor&)colorB;

+(KSGColor)scalarProductOfColor:(const KSGColor&)colorA 
                     withColor:(const KSGColor&)colorB;

// creates a color with components corresponding to the named color. The name
// should be one of the colors available in the Apple or Crayons NSColorList
// objects. If the name isn't found, then black is returned.
+(KSGColor)makeColor:(NSString *)colorName;


@end
