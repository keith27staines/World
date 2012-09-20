//
//  KSCBVHNode.h
//  World
//
//  Created by Keith Staines on 09/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

@class KSGGameObject;
@class KSCBoundingVolume;

#import <Foundation/Foundation.h>
#import "KSCBody.h"

@interface KSCBVHNode : NSObject
{
    KSCBVHNode        *  parentNode;
    KSCBVHNode        *  childNode1;
    KSCBVHNode        *  childNode2;
    
    KSCBoundingVolume *  boundingVolume;
    NSObject <KSCBody>* __weak body;
}

@property (strong) KSCBVHNode         * parentNode;
@property (strong) KSCBVHNode         * childNode1;
@property (strong) KSCBVHNode         * childNode2;
@property (weak)   NSObject <KSCBody> * body;
@property (strong) KSCBoundingVolume  * boundingVolume;

////////////////////////////////////////////////////////////////////////////////
// node
// convenience constructor
+(id)node;


////////////////////////////////////////////////////////////////////////////////
// nodeFromNode:
// convenience constructor
+(id)nodeWithParentNode:(KSCBVHNode*)parent 
                   body:(NSObject*)object 
         boundingVolume:(KSCBoundingVolume*)volume;

////////////////////////////////////////////////////////////////////////////////
// isLeaf
// Returns true if this node has a game object, otherwise false
-(BOOL)isLeaf;

////////////////////////////////////////////////////////////////////////////////
// addPotentialContactsTo
// recurse through child nodes adding to the potential Contacts list if their
// bounding volume geometry overlaps.
-(NSInteger)addPotentialContactsTo:(NSMutableDictionary*)potentialContacts                           
                        startIndex:(NSInteger)nextIndex 
                          maxIndex:(NSInteger)maxIndex;

////////////////////////////////////////////////////////////////////////////////
// addPotentialContactsWith
// recurse through child nodes adding to the potential Contacts list if the
// bounding volume geometry overlaps with the geometry of the specified node.
-(NSInteger)addPotentialContactsWith:(KSCBVHNode*)otherNode
                                  to:(NSMutableDictionary*)potentialContacts 
                          startIndex:(NSInteger)startIndex 
                            maxIndex:(NSInteger)maxIndex;

////////////////////////////////////////////////////////////////////////////////
// overlaps:
// Returns YES if there is an overla between this node's collision geometry and
// that of the specified node
-(BOOL)overlaps:(KSCBVHNode*)otherNode;

////////////////////////////////////////////////////////////////////////////////
// insert
// Inserts the specified object with the specified bounding volume
-(void)insertBody:(NSObject<KSCBody>*)newBody 
       withVolume:(KSCBoundingVolume*)newVolume;

////////////////////////////////////////////////////////////////////////////////
// remove
// Removes the node from the hierarchy. The node and all its children are deleted.
// The node's sibling's internal data is copied to the parent and then it too 
// is deleted (its child nodes remaining intact in their new home in parent).
-(void)remove;

////////////////////////////////////////////////////////////////////////////////
// recalculateBoundingVolume
// Recalculates the volume of this node without asking children to do the same
-(void)recalculateBoundingVolume;

////////////////////////////////////////////////////////////////////////////////
// recalculateBoundingVolumeRecursively
// Nodes recalcuates its volume and then tells its parent to do the same
-(void)recalculateBoundingVolumeRecursively;


@end



