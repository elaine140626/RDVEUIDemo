/*
 *  RDATMHud.h
 *  RDATMHud
 *
 *  Created by Marcel Müller on 2011-03-01.
 *  Copyright (c) 2010-2011, Marcel Müller (atomcraft)
 *  All rights reserved.
 *
 *	https://github.com/atomton/ATMHud
 */

#import <UIKit/UIKit.h>
@class RDATMHudView, RDATMSoundFX, RDATMHudQueueItem;
@protocol RDATMHudDelegate;

typedef NS_ENUM(NSInteger,ATMHudAccessoryPosition) {
	ATMHudAccessoryPositionTop = 0,
	ATMHudAccessoryPositionRight,
	ATMHudAccessoryPositionBottom,
	ATMHudAccessoryPositionLeft
} ;

@interface RDATMHud : UIViewController {
	CGFloat margin;
	CGFloat padding;
	CGFloat alpha;
	CGFloat appearScaleFactor;
	CGFloat disappearScaleFactor;
	CGFloat progressBorderRadius;
	CGFloat progressBorderWidth;
	CGFloat progressBarRadius;
	CGFloat progressBarInset;
	
	CGPoint center;
	
	BOOL shadowEnabled;
	BOOL blockTouches;
	BOOL allowSuperviewInteraction;
	
	NSString *showSound;
	NSString *updateSound;
	NSString *hideSound;
	
	//id <RDATMHudDelegate> delegate;
	ATMHudAccessoryPosition accessoryPosition;
	
	@private
	RDATMHudView *__view;
	RDATMSoundFX *sound;
	NSMutableArray *displayQueue;
	NSInteger queuePosition;
}
@property (nonatomic, weak)id <RDATMHudDelegate> delegate;
@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, assign) CGFloat appearScaleFactor;
@property (nonatomic, assign) CGFloat disappearScaleFactor;
@property (nonatomic, assign) CGFloat progressBorderRadius;
@property (nonatomic, assign) CGFloat progressBorderWidth;
@property (nonatomic, assign) CGFloat progressBarRadius;
@property (nonatomic, assign) CGFloat progressBarInset;

@property (nonatomic, assign) CGPoint center;

@property (nonatomic, assign) BOOL shadowEnabled;
@property (nonatomic, assign) BOOL blockTouches;
@property (nonatomic, assign) BOOL allowSuperviewInteraction;

@property (nonatomic, copy) NSString *showSound;
@property (nonatomic, copy) NSString *updateSound;
@property (nonatomic, copy) NSString *hideSound;

@property (nonatomic, assign) ATMHudAccessoryPosition accessoryPosition;

@property (nonatomic, strong) RDATMHudView *__view;
@property (nonatomic, strong) RDATMSoundFX *sound;
@property (nonatomic, strong) NSMutableArray *displayQueue;
@property (nonatomic, assign) NSInteger queuePosition;

+ (NSString *)buildInfo;

- (id)initWithDelegate:(id)hudDelegate;

- (void)setCaption:(NSString *)caption;
- (void)setImage:(UIImage *)image;
- (void)setActivity:(BOOL)activity;
- (void)setActivityStyle:(UIActivityIndicatorViewStyle)activityStyle;
- (void)setFixedSize:(CGSize)fixedSize;
- (void)setProgress:(CGFloat)progress;

- (void)addQueueItem:(RDATMHudQueueItem *)item;
- (void)addQueueItems:(NSArray *)items;
- (void)clearQueue;
- (void)startQueue;
- (void)showNextInQueue;
- (void)showQueueAtIndex:(NSInteger)index;

- (void)show;
- (void)update;
- (void)hide;
- (void)hideAfter:(NSTimeInterval)delay;

- (void)playSound:(NSString *)soundPath;
- (void)releaseHud;//20170419 解决不释放
@end
