//
//  JvPieChart.h
//  JvPieChartDemo
//
//  Created by Jovi Du on 15/11/2016.
//  Copyright © 2016 Jovistudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JvPieChartItem;

@interface JvPieChart : UIView

@property (strong, nonatomic) NSMutableArray<JvPieChartItem *> *items;

@property (assign, nonatomic) CGFloat startAngle;
@property (assign, nonatomic) CGFloat offsetScale;

- (void)drawChart;

@end

#pragma mark -

@interface JvPieChartItem : NSObject

+ (instancetype)itemWithValue:(float)value
                        color:(UIColor *)color
                         text:(NSString *)text
                    textColor:(UIColor *)textColor;

@property (assign, nonatomic) float value;
@property (strong, nonatomic) UIColor *color;
@property (copy, nonatomic) NSString *text;
@property (strong, nonatomic) UIColor *textColor;

@end
