//
//  KSGTextureManager.h
//  World
//
//  Created by Keith Staines on 03/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSGResourceManager.h"


@interface KSGTextureManager : KSGResourceManager
{

}

////////////////////////////////////////////////////////////////////////////////
// sendToGL
// sends all current textures to texture objects
-(void)sendToGL;

@end
