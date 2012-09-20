//
//  KSCBody.h
//  World
//
//  Created by Keith Staines on 18/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KSCBVHNode;
@class KSGUID;

@protocol KSCBody <NSObject>

 @required

-(void) setBoundingNode:(KSCBVHNode*)aNode;
-(KSCBVHNode*) boundingNode;
-(KSGUID*)  uid;

@end
