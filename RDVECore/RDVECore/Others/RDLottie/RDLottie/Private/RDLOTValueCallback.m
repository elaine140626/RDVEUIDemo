//
//  RDLOTValueCallback.m
//  RDLottie
//
//  Created by brandon_withrow on 12/15/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "RDLOTValueCallback.h"

@implementation RDLOTColorValueCallback

+ (instancetype _Nonnull)withCGColor:(CGColorRef _Nonnull)color {
  RDLOTColorValueCallback *colorCallback = [[self alloc] init];
  colorCallback.colorValue = color;
  return colorCallback;
}

- (CGColorRef)colorForFrame:(CGFloat)currentFrame startKeyframe:(CGFloat)startKeyframe endKeyframe:(CGFloat)endKeyframe interpolatedProgress:(CGFloat)interpolatedProgress startColor:(CGColorRef)startColor endColor:(CGColorRef)endColor currentColor:(CGColorRef)interpolatedColor {
  return self.colorValue;
}

@end

@implementation RDLOTNumberValueCallback

+ (instancetype _Nonnull)withFloatValue:(CGFloat)numberValue {
  RDLOTNumberValueCallback *numberCallback = [[self alloc] init];
  numberCallback.numberValue = numberValue;
  return numberCallback;
}

- (CGFloat)floatValueForFrame:(CGFloat)currentFrame startKeyframe:(CGFloat)startKeyframe endKeyframe:(CGFloat)endKeyframe interpolatedProgress:(CGFloat)interpolatedProgress startValue:(CGFloat)startValue endValue:(CGFloat)endValue currentValue:(CGFloat)interpolatedValue {
  return self.numberValue;
}

@end

@implementation RDLOTPointValueCallback

+ (instancetype _Nonnull)withPointValue:(CGPoint)pointValue {
  RDLOTPointValueCallback *callback = [[self alloc] init];
  callback.pointValue = pointValue;
  return callback;
}

- (CGPoint)pointForFrame:(CGFloat)currentFrame startKeyframe:(CGFloat)startKeyframe endKeyframe:(CGFloat)endKeyframe interpolatedProgress:(CGFloat)interpolatedProgress startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint currentPoint:(CGPoint)interpolatedPoint {
  return self.pointValue;
}

@end

@implementation RDLOTSizeValueCallback

+ (instancetype _Nonnull)withPointValue:(CGSize)sizeValue {
  RDLOTSizeValueCallback *callback = [[self alloc] init];
  callback.sizeValue = sizeValue;
  return callback;
}

- (CGSize)sizeForFrame:(CGFloat)currentFrame startKeyframe:(CGFloat)startKeyframe endKeyframe:(CGFloat)endKeyframe interpolatedProgress:(CGFloat)interpolatedProgress startSize:(CGSize)startSize endSize:(CGSize)endSize currentSize:(CGSize)interpolatedSize {
  return self.sizeValue;
}

@end

@implementation RDLOTPathValueCallback

+ (instancetype _Nonnull)withCGPath:(CGPathRef _Nonnull)path {
  RDLOTPathValueCallback *callback = [[self alloc] init];
  callback.pathValue = path;
  return callback;
}

- (CGPathRef)pathForFrame:(CGFloat)currentFrame startKeyframe:(CGFloat)startKeyframe endKeyframe:(CGFloat)endKeyframe interpolatedProgress:(CGFloat)interpolatedProgress {
  return self.pathValue;
}

@end
