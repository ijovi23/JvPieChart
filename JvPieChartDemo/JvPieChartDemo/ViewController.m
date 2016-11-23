//
//  ViewController.m
//  JvPieChartDemo
//
//  Created by Jovi Du on 15/11/2016.
//  Copyright © 2016 Jovistudio. All rights reserved.
//

#import "ViewController.h"
#import "JvPieChart.h"

@interface ViewController ()
@property (strong, nonatomic) JvPieChart *chart;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.chart = [[JvPieChart alloc] init];
    self.chart.backgroundColor = [UIColor yellowColor];
    self.chart.bounds = CGRectMake(0, 0, 200, 200);
    self.chart.center = self.view.center;
    
    self.chart.startAngle = - M_PI_2;
    self.chart.offsetScale = 0.08;
    
    JvPieChartItem *item1 = [JvPieChartItem itemWithValue:35 color:[UIColor blueColor] text:@"35" textColor:[UIColor whiteColor]];
    JvPieChartItem *item2 = [JvPieChartItem itemWithValue:100 color:[UIColor orangeColor] text:@"100" textColor:[UIColor whiteColor]];
    JvPieChartItem *item3 = [JvPieChartItem itemWithValue:100 color:[UIColor greenColor] text:@"50" textColor:[UIColor whiteColor]];
    
    [self.chart.items addObjectsFromArray:@[item1, item2, item3]];
    
    [self.view addSubview:self.chart];
    
    [self.chart drawChart];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
