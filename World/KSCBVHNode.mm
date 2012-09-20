//
//  KSCBVHNode.mm
//  World
//
//  Created by Keith Staines on 09/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "KSCBVHNode.h"
#import "KSGGameObject.h"
#import "KSCBoundingVolume.h"
#import "KSCPotentialContact.h"

@implementation KSCBVHNode
@synthesize parentNode;
@synthesize childNode1;
@synthesize childNode2;
@synthesize boundingVolume;

-(id)init
{
    self = [super init];
    if (self)
    {
        parentNode     = nil;
        childNode1     = nil;
        childNode2     = nil;
        boundingVolume = nil;
        body           = nil;
    }
    
    return self;
}



////////////////////////////////////////////////////////////////////////////////
//body
-(NSObject<KSCBody>*)body
{
    return body;
}


////////////////////////////////////////////////////////////////////////////////
// setBody
-(void)setBody:(NSObject<KSCBody>*)aBody
{
    body = aBody;
    [aBody setBoundingNode:self];
}
////////////////////////////////////////////////////////////////////////////////
// node
// convenience constructor
+(id)node
{
    return   [[[self class] alloc] init];
}

////////////////////////////////////////////////////////////////////////////////
// nodeFromNode:
// convenience constructor
+(id)nodeWithParentNode:(KSCBVHNode*)parent 
                 body:(NSObject<KSCBody>*)object 
         boundingVolume:(KSCBoundingVolume*)volume
{
    KSCBVHNode* newNode    = [[self class] node];
    [newNode setParentNode:parent];
    [newNode setBoundingVolume:volume];
    [newNode setBody:object];
    return newNode;
}

////////////////////////////////////////////////////////////////////////////////
// addPotentialContactsTo
// recurse through child nodes adding to the potential Contacts list if the
// bounding volume geometry overlaps.
-(NSInteger)addPotentialContactsTo:(NSMutableDictionary *)potentialContacts                           
                        startIndex:(NSInteger)startIndex 
                          maxIndex:(NSInteger)maxIndex;
{
    // Exit immediately if there is no room to add more contacts
    // or this node is a leaf (contains a game object)
    if ( startIndex == maxIndex || [self isLeaf] ) 
    {
        return 0;
    }
    
    // add potential contacts between child nodes
    return [childNode1 addPotentialContactsWith:childNode2 
                                             to:potentialContacts 
                                     startIndex:startIndex 
                                       maxIndex:maxIndex];
}


////////////////////////////////////////////////////////////////////////////////
// addPotentialContactsWith
// recurse through child nodes adding to the potential Contacts list if the
// bounding volume geometry overlaps with the geometry of the specified node.
-(NSInteger)addPotentialContactsWith:(KSCBVHNode*)otherNode
                                  to:(NSMutableDictionary*)potentialContacts 
                          startIndex:(NSInteger)startIndex 
                            maxIndex:(NSInteger)maxIndex; 
{
    
    // Recursive search. The first test is whether we need to recurse further. 
    // If we have run out of room (startIndex == maxIndex) or there is no overlap
    // between volumes at the current level, there is no need to continue.
    if ( startIndex == maxIndex || ![self overlaps:otherNode]) 
    {
        // No overlap (or out of room)
        return 0;
    }
    
    // We know that there is some overlap between this node and the other node
    
    // If both nodes are leaf nodes then we have overlapping coarse collision
    // geometry and therefore there is a potential contact.
    if ( (self.isLeaf && otherNode.isLeaf)  ) 
    {  
        NSObject<KSCBody> * body1 = self.body;
        NSObject<KSCBody> * body2 = otherNode.body;
        if ( body1 == body2 ) 
        {
            // the body cannot be in collision with itself
            return 0;
        }
        KSCPotentialContact * contact;
        contact = [KSCPotentialContact potentialContactWithBodyA:body1 
                                                           bodyB:body2];
        
        if ([potentialContacts objectForKey:[contact name]]) 
        {
            // contact has already been added
            return 0;
        }
        
        // add the contact
        [potentialContacts setObject:contact forKey:[contact name]];        
        return 1;
    }
    
    // Three possibilities now: 1) Neither are leaves; 2) this node is a leaf
    // but the other is not; 3) the other node is a leaf but this node is not


    NSInteger count = 0;
    
    if ( otherNode.isLeaf ||  (![self isLeaf] && [[self boundingVolume] volume] > 
                                                 [[otherNode boundingVolume] volume] ) ) 
    {
        // This node is not a leaf and therefore has children. 
        // The other node might also be a leaf, but if it is, this node has 
        // the larger volume and should be recursed into first
        
        // deal with contacts between this node's first child and the other node
        count += [childNode1 addPotentialContactsWith:otherNode 
                                              to:potentialContacts
                                           startIndex:startIndex 
                                             maxIndex:maxIndex];
        startIndex += count;

        // deal with contacts between this node's second child and the other node
        if (startIndex == maxIndex) 
        {
            // Out of room, just return the number added under child 1
            return count;
        }        

        // still room so process this node's second child
        count += [childNode2 addPotentialContactsWith:otherNode 
                                              to:potentialContacts 
                                           startIndex:startIndex 
                                             maxIndex:maxIndex];
    }
    else
    {
        // The other node is not a leaf. This node might be, but if it is, the
        // other node has the larger volume.
        
        // deal with contacts between the other node's first child and this node
        count += [self addPotentialContactsWith:[otherNode childNode1] 
                                                to:potentialContacts
                                             startIndex:startIndex 
                                               maxIndex:maxIndex];
        startIndex += count;
        
        // deal with contacts between the other node's second child and this node
        if (startIndex == maxIndex) 
        {
            // Out of room, just return the number added under child 1
            return count;
        }        
        
        // still room so process this node's second child
        count += [self addPotentialContactsWith:[otherNode childNode2] 
                                        to:potentialContacts 
                                     startIndex:startIndex 
                                       maxIndex:maxIndex];
    }

    return count;    
    
}

////////////////////////////////////////////////////////////////////////////////
// insert
// Inserts the specified game object with the specified bounding volume
-(void)insertBody:(NSObject<KSCBody>*)newBody 
       withVolume:(KSCBoundingVolume*)newVolume
{
    
    // If this node is a leaf node then we must spawn two child nodes, one to 
    // hold the new body, and move the info from this node to the other
    if ([self isLeaf]) 
    {
        // as we are a leaf, we currently don't have child nodes, but this
        // is about to change...
        
        // child 1 holds what we previously held
        self.childNode1 = [KSCBVHNode nodeWithParentNode:self 
                                                    body:self.body 
                                          boundingVolume:self.boundingVolume];
    
        self.childNode2 = [KSCBVHNode nodeWithParentNode:self 
                                                    body:newBody 
                                          boundingVolume:newVolume];
        
        // we are no longer a leaf so release ownership of the object
        [self setBody:nil];
        
        // finally, we need to recalculate our volume which depends on
        // the volume of our children, and they have just changed. This
        // knocks on up the tree to our parent and its parent, etc.
        [self recalculateBoundingVolumeRecursively];
        
    }
    else
    {
        // We will pass on the game object to one of our children. We choose
        // the one that will grow the least
        KSCBoundingVolume* grownChild1Volume;
        KSCBoundingVolume* grownChild2Volume;
        
        grownChild1Volume = [KSCBoundingVolume 
                             boundingVolumeFromVolume1:childNode1.boundingVolume 
                                               volume2:newVolume];
        
        grownChild2Volume = [KSCBoundingVolume 
                             boundingVolumeFromVolume1:childNode2.boundingVolume 
                                               volume2:newVolume];
        
        // We actually compare areas rather than volumes which is a bit counter-
        // intuitive, but that is the recommended heuristic
        if (grownChild1Volume.area < grownChild2Volume.area) 
        {
            // Child1 will grow least so assign it the new data
            [childNode1 insertBody:newBody withVolume:newVolume];
        }
        else
        {
            // Child2 will grow the least so assign it the new data
            [childNode2 insertBody:newBody withVolume:newVolume];            
        }
    }
    
    return;
    
}

////////////////////////////////////////////////////////////////////////////////
// remove
// Removes the node and all its children from the hierarchy. A side effect is 
// that the node's sibling is also deleted, but all of its data is copied up
// to the parent, thus preserving the integrity of the data structure
-(void)remove
{
    // As part of this method we will be telling this node's parent to release
    // us, leading to a premature dealloc before this method is finished, so
    // we must retain ourselves
    
    if (parentNode) 
    {
        // Find this node's sibling
        KSCBVHNode* sibling = nil;
        if ( self == [parentNode childNode1] )
        {
            // self IS childNode1, therefore self's sibling is...
            sibling = [parentNode childNode2];
        }
        else
        {
            // self IS childNode2, therefore self's sibling is...
            sibling = [parentNode childNode1];
        }
        
        // now reassign the sibling's data to our common parent (because
        // the sibling will also be removed in a moment but we want to 
        // preserve its data
        [parentNode setBoundingVolume:[sibling boundingVolume]];
        [parentNode setBody:[sibling body]];
        //[[parentNode body] setBoundingNode:parentNode];//redundant???
        
        // the children of the sibling are given to the new parent and released
        // by the sibling.
        [parentNode setChildNode1:[sibling childNode1]];
        [parentNode setChildNode2:[sibling childNode2]];
        [sibling setChildNode1:nil];
        [sibling setChildNode2:nil];
        
        // The children have to know about the new parent
        [[parentNode childNode1] setParentNode:parentNode];
        [[parentNode childNode2] setParentNode:parentNode];
        
        // prepare to delete the sibling, prevent unneccessary operations
        [sibling setParentNode:nil];
        [sibling remove];
        sibling = nil;
        
        // the parent node will have changed size, because it now has different
        // children. And therefore, the parent's parent might have changed 
        // too, and so on up the tree. We therefore do a recursive recalc.
        [parentNode recalculateBoundingVolume];
    }
    
    // let go of this node's reference to its body, and the body's reference
    // to this node if it still thinks this is its node.
    if (self == [body boundingNode]) [body setBoundingNode:nil];
    [self setBody:nil];
    
    // Remove this node's children, first setting their parent pointer to nil to 
    // avoid unwanted processing
    [childNode1 setParentNode:nil];       
    [childNode2 setParentNode:nil];
    [childNode1 remove];
    [childNode2 remove];
    
}


////////////////////////////////////////////////////////////////////////////////
// recalculateBoundingVolume
-(void)recalculateBoundingVolume
{
    if ( self.isLeaf ) 
    {
        // as we are a leaf, our volume is constant so there is nothing to do
        return;
    }
    
    KSCBoundingVolume* newVolume = [KSCBoundingVolume 
                          boundingVolumeFromVolume1:childNode1.boundingVolume
                                            volume2:childNode2.boundingVolume];
    [self setBoundingVolume:newVolume];
    
}

////////////////////////////////////////////////////////////////////////////////
// recalculateBoundingVolumeRecursively
-(void)recalculateBoundingVolumeRecursively
{
    [self recalculateBoundingVolume];
    [parentNode recalculateBoundingVolumeRecursively];
}

////////////////////////////////////////////////////////////////////////////////
// overlaps:
// Returns YES if there is an overlap between this node's collision geometry and
// that of the specified node
-(BOOL)overlaps:(KSCBVHNode*)otherNode
{
    return [[self boundingVolume] overlaps:otherNode.boundingVolume];
}
        

////////////////////////////////////////////////////////////////////////////////
// isLeaf
// Returns true if this node has a body, otherwise false
-(BOOL)isLeaf
{
    return ( nil != body );
}


@end
