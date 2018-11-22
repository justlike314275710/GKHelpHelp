//
//  PSServicePrisonsCell.m
//  PrisonService
//
//  Created by kky on 2018/11/22.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSServicePrisonsCell.h"

@implementation PSServicePrisonsCell

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIView *bgview = [[UIView alloc] initWithFrame:CGRectMake(15,15,SCREEN_WIDTH-30,self.height-30)];
        [self addBorderToLayer:bgview];
        [self addSubview:bgview];
        
        for (int i = 0; self.Prisons.count+1<3;i++ ) {
            UIButton *prisonBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [bgview addSubview:prisonBtn];
            prisonBtn.frame = CGRectMake(0,40*i, bgview.width, 40);
            
            //虚线
            if (i!=0) {
                UIImageView *lineImg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 40*i,bgview.width-30,2)];
                [self drawLineByImageView:lineImg];
                [bgview addSubview:lineImg];
            }
            
            UIImageView *iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(16,12+40*i,16, 16)];
            iconImage.image = [UIImage imageNamed:@"已勾选"];
            [bgview addSubview:iconImage];
            
    
            UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconImage.right+5,40*i,100, 40)];
            keyLabel.text = @"服刑人员";
            keyLabel.textColor = UIColorFromRGB(102, 102, 102);
            keyLabel.font = FontOfSize(12);
            keyLabel.textAlignment  = NSTextAlignmentLeft;
            [bgview addSubview:keyLabel];
            if (i==self.Prisons.count) {
                keyLabel.textColor = UIColorFromRGB(4, 47, 136);
                keyLabel.font = FontOfSize(14);
                keyLabel.text = @"绑定服刑人员";
            }
            
            UILabel *valueLab = [[UILabel alloc] initWithFrame:CGRectMake(bgview.width-220, 40*i, 200,40)];
            valueLab.text = @"李天一";
            valueLab.font = FontOfSize(12);
            valueLab.textColor = UIColorFromRGB(102, 102, 102);
            valueLab.textAlignment = NSTextAlignmentRight;
            [bgview addSubview:valueLab];
            
        }

    }
    return self;
}

- (void)addBorderToLayer:(UIView *)view
{

    UIBezierPath *maskPath=[[UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)] bezierPathByReversingPath];
    CAShapeLayer *border = [CAShapeLayer layer];
    // 线条颜色
    border.strokeColor = UIColorFromRGB(194,194, 194).CGColor;
    border.masksToBounds = YES;
    
    border.fillColor = nil;
    border.path = maskPath.CGPath;
    border.frame = view.bounds;
    border.lineWidth = 1;
    border.lineCap = @"square";
    // 第一个是 线条长度 第二个是间距 nil时为实线
    border.lineDashPattern = @[@6, @4];
    [view.layer addSublayer:border];
}

- (void)drawLineByImageView:(UIImageView *)imageView {
    
    UIGraphicsBeginImageContext(imageView.frame.size);   //开始画线 划线的frame
    [imageView.image drawInRect:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    //设置线条终点形状
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    
    CGContextRef line = UIGraphicsGetCurrentContext();
    // 设置颜色
    CGContextSetStrokeColorWithColor(line, [UIColor darkGrayColor].CGColor);
    
    CGFloat lengths[] = {5,2};//先画4个点再画2个点
    CGContextSetLineDash(line,0, lengths,2);//注意2(count)的值等于lengths数组的长度
    
    CGContextMoveToPoint(line, 0.0, 2.0);    //开始画线
    CGContextAddLineToPoint(line,imageView.frame.size.width,2.0);
    CGContextStrokePath(line);
    // UIGraphicsGetImageFromCurrentImageContext()返回的就是image
    UIImage *image =   UIGraphicsGetImageFromCurrentImageContext();
    imageView.image = image;
}



@end
