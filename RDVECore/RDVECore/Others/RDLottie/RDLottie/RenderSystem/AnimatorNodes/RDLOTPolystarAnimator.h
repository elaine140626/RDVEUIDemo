//
//  RDLOTPolystarAnimator.h
//  RDLottie
//
//  Created by brandon_withrow on 7/27/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "RDLOTAnimatorNode.h"
#import "RDLOTShapeStar.h"

@interface RDLOTPolystarAnimator : RDLOTAnimatorNode

- (instancetype _Nonnull)initWithInputNode:(RDLOTAnimatorNode *_Nullable)inputNode
                             shapeStar:(RDLOTShapeStar *_Nonnull)shapeStar;

@end
