//
//  RDLOTShapeGradientFill.m
//  RDLottie
//
//  Created by brandon_withrow on 7/26/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "RDLOTShapeGradientFill.h"
#import "CGGeometry+RDLOTAdditions.h"

@implementation RDLOTShapeGradientFill

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
  
  NSNumber *type = jsonDictionary[@"t"];
  
  if (type.integerValue != 1) {
    _type = RDLOTGradientTypeRadial;
  } else {
    _type = RDLOTGradientTypeLinear;
  }
  
  NSDictionary *start = jsonDictionary[@"s"];
  if (start) {
    _startPoint = [[RDLOTKeyframeGroup alloc] initWithData:start];
  }
  
  NSDictionary *end = jsonDictionary[@"e"];
  if (end) {
    _endPoint = [[RDLOTKeyframeGroup alloc] initWithData:end];
  }
  
  NSDictionary *gradient = jsonDictionary[@"g"];
  if (gradient) {
    NSDictionary *unwrappedGradient = gradient[@"k"];
    _numberOfColors = gradient[@"p"];
    _gradient = [[RDLOTKeyframeGroup alloc] initWithData:unwrappedGradient];
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
}
@end
