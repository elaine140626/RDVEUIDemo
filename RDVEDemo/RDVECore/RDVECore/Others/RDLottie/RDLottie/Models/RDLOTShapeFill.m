//
//  RDLOTShapeFill.m
//  RDLottieAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "RDLOTShapeFill.h"
#import "CGGeometry+RDLOTAdditions.h"

@implementation RDLOTShapeFill

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary {
  
  if (jsonDictionary[@"nm"] ) {
    _keyname = [jsonDictionary[@"nm"] copy];
  }
  
  NSDictionary *color = jsonDictionary[@"c"];
  if (color) {
    _color = [[RDLOTKeyframeGroup alloc] initWithData:color];
  }
  
  NSDictionary *opacity = jsonDictionary[@"o"];
  if (opacity) {
    _opacity = [[RDLOTKeyframeGroup alloc] initWithData:opacity];
    [_opacity remapKeyframesWithBlock:^CGFloat(CGFloat inValue) {
      return RDLOT_RemapValue(inValue, 0, 100, 0, 1);
    }];
  }
  
  NSNumber *evenOdd = jsonDictionary[@"r"];
  if (evenOdd.integerValue == 2) {
    _evenOddFillRule = YES;
  } else {
    _evenOddFillRule = NO;
  }
  
  NSNumber *fillEnabled = jsonDictionary[@"fillEnabled"];
  _fillEnabled = fillEnabled.boolValue;
}

@end
