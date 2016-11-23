//
//  JvPieChart.m
//  JvPieChartDemo
//
//  Created by Jovi Du on 15/11/2016.
//  Copyright © 2016 Jovistudio. All rights reserved.
//

#import "JvPieChart.h"

@interface JvPieChart ()
@property (assign, nonatomic) CGFloat radius;
@property (assign, nonatomic) CGFloat offset;

@property (strong, nonatomic) NSMutableArray<CAShapeLayer *> *layers;
@property (strong, nonatomic) NSMutableArray<UILabel *> *labels;
@property (strong, nonatomic) NSMutableArray<NSNumber *> *startPercents;
@property (strong, nonatomic) NSMutableArray<NSNumber *> *endPercents;

- (CGPoint)centerForItemAtIndex:(NSInteger)index;
- (CGPoint)labelCenterForItemAtIndex:(NSInteger)index;

@end

@implementation JvPieChart

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.startAngle = - M_PI;
        self.offsetScale = 0.08;
    }
    return self;
}

- (NSMutableArray<JvPieChartItem *> *)items {
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}

- (void)updateRadiusAndOffset {
    CGFloat edgeLen = MIN(self.bounds.size.width, self.bounds.size.height);
    self.radius = edgeLen * 0.5 * (1.0 - self.offsetScale);
    self.offset = edgeLen * 0.5 - self.radius;
}

- (CGPoint)centerForItemAtIndex:(NSInteger)index {
    CGFloat midAngle = (self.startPercents[index].doubleValue + self.endPercents[index].doubleValue) * M_PI + self.startAngle;
    CGFloat offsetX = self.offset * cos(midAngle);
    CGFloat offsetY = self.offset * sin(midAngle);
    
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    center.x += offsetX;
    center.y += offsetY;
    return center;
}

- (CGPoint)labelCenterForItemAtIndex:(NSInteger)index {
    CGFloat midAngle = (self.startPercents[index].doubleValue + self.endPercents[index].doubleValue) * M_PI + self.startAngle;
    CGFloat offsetX = self.radius * 0.6 * cos(midAngle);
    CGFloat offsetY = self.radius * 0.6 * sin(midAngle);
    
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    center.x += offsetX;
    center.y += offsetY;
    return center;
}


- (void)drawChart {
    if (!(self.items.count > 0)) {
        return;
    }
    
    [self updateRadiusAndOffset];
    
    float total = [[self.items valueForKeyPath:@"@sum.value"] floatValue];
    __block float currentTotal = 0;
    self.endPercents = [NSMutableArray array];
    self.startPercents = [NSMutableArray array];
    [self.items enumerateObjectsUsingBlock:^(JvPieChartItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx == 0) {
            [self.startPercents addObject:@(0)];
        } else {
            [self.startPercents addObject:self.endPercents.lastObject];
        }
        
        if (total == 0) {
            [self.endPercents addObject:@(1.0 / self.items.count * (idx + 1))];
        } else {
            currentTotal += obj.value;
            [self.endPercents addObject:@(currentTotal / total)];
        }
    }];
    
    [self _drawChartLayers];
}

- (void)_drawChartLayers {
    self.layers = [NSMutableArray array];
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    self.labels = [NSMutableArray array];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger uniqueItemIndex = -1;
    for (NSInteger i = 0; i < self.items.count; i++) {
        CGFloat startPercent = [self.startPercents[i] doubleValue];
        CGFloat endPercent = [self.endPercents[i] doubleValue];
        CAShapeLayer *layer = [self.class pieLayerWithRadius:self.radius
                                                       color:self.items[i].color
                                             startPercentage:startPercent
                                               endPercentage:endPercent
                                                  startAngle:self.startAngle
                                                    position:[self centerForItemAtIndex:i]];
        [self.layer addSublayer:layer];
        [self.layers addObject:layer];
        
        if (startPercent <= 0 && endPercent >= 1) {
            uniqueItemIndex = i;
        }
    }
    
    if (uniqueItemIndex >= 0) {
        UILabel *label = [self.class labelWithText:self.items[uniqueItemIndex].text
                                         textColor:self.items[uniqueItemIndex].textColor
                                       shadowColor:self.items[uniqueItemIndex].color
                                              size:CGSizeMake(self.radius, self.radius * 0.5)
                                          position:[self centerForItemAtIndex:uniqueItemIndex]];
        [self addSubview:label];
        [self.labels addObject:label];
        
    } else {
        for (NSInteger i = 0; i < self.items.count; i++) {
            NSString *text = self.items[i].text;
            UILabel *label = [self.class labelWithText:text
                                             textColor:self.items[i].textColor
                                           shadowColor:self.items[i].color
                                                  size:CGSizeMake(self.radius, self.radius * 0.5)
                                              position:[self labelCenterForItemAtIndex:i]];
            [self addSubview:label];
            [self.labels addObject:label];
        }
    }
    
}

+ (CAShapeLayer *)pieLayerWithRadius:(CGFloat)radius
                               color:(UIColor *)color
                     startPercentage:(CGFloat)startPercentage
                       endPercentage:(CGFloat)endPercentage
                          startAngle:(CGFloat)startAngle
                            position:(CGPoint)position
{
    CAShapeLayer *circle = [CAShapeLayer layer];
    
    CGPoint center = position;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:(radius / 2)
                                                    startAngle:startAngle
                                                      endAngle:(startAngle + M_PI * 2)
                                                     clockwise:YES];
    
    circle.fillColor   = [UIColor clearColor].CGColor;
    circle.strokeColor = color.CGColor;
    circle.strokeStart = startPercentage;
    circle.strokeEnd   = endPercentage;
    circle.lineWidth   = radius;
    circle.path        = path.CGPath;
    
    return circle;
}

+ (UILabel *)labelWithText:(NSString *)text
                 textColor:(UIColor *)textColor
               shadowColor:(UIColor *)shadowColor
                      size:(CGSize)size
                  position:(CGPoint)position
{
    UILabel *lab = [UILabel new];
    lab.bounds = CGRectMake(0, 0, size.width, size.height);
    lab.center = position;
    lab.textColor = textColor;
    lab.text = text;
    lab.textAlignment = NSTextAlignmentCenter;
    
    lab.shadowColor = shadowColor;
    lab.shadowOffset = CGSizeMake(0, 0);
    
    lab.font = [UIFont systemFontOfSize:(size.height * 0.5)];
    
    return lab;
}

@end


#pragma mark -

@implementation JvPieChartItem

+ (instancetype)itemWithValue:(float)value color:(UIColor *)color text:(NSString *)text textColor:(UIColor *)textColor {
    JvPieChartItem *item = [[JvPieChartItem alloc] init];
    item.value = value;
    item.color = color;
    item.text = text;
    item.textColor = textColor;
    return item;
}

@end
