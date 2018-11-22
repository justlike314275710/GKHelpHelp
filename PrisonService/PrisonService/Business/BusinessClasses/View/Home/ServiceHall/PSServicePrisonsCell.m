//
//  PSServicePrisonsCell.m
//  PrisonService
//
//  Created by kky on 2018/11/22.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSServicePrisonsCell.h"


@interface PSServicePrisonsCell ()
@property (nonatomic,strong)UIView *bgView;

@end

@implementation PSServicePrisonsCell

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)setPrisons:(NSArray *)Prisons {
    _Prisons = Prisons;
    if (_bgView){
        [_bgView removeFromSuperview];
        _bgView = nil;
    }
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(15,15,SCREEN_WIDTH-30,self.height-30)];
    [self addBorderToLayer:_bgView];
    [self addSubview:_bgView];
    
    for (int i = 0; i<_Prisons.count+1;i++ ) {
        
        UIButton *prisonBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i==_Prisons.count) {
            @weakify(self);
            [prisonBtn bk_whenTapped:^{
                @strongify(self);
                //绑定囚犯
                if(self.bingBlock) {
                    self.bingBlock();
                }
            }];
        } else {
            prisonBtn.tag = 10+i;
            [prisonBtn addTarget:self action:@selector(changAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        [_bgView addSubview:prisonBtn];
        prisonBtn.frame = CGRectMake(0,40*i,_bgView.width, 40);
        //虚线
        if (i!=0) {
            UIImageView *lineImg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 40*i,_bgView.width-30,2)];
            [self drawLineByImageView:lineImg];
            [_bgView addSubview:lineImg];
        }
        
        UIImageView *iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(16,12+40*i,16, 16)];
        iconImage.tag = 100+i;
        iconImage.image = [UIImage imageNamed:@"已勾选"];
        [_bgView addSubview:iconImage];
        if (i==0) {
             iconImage.image = [UIImage imageNamed:@"已勾选"];
        } else if(i<_Prisons.count) {
             iconImage.image = [UIImage imageNamed:@"未选"];
        } else {
             iconImage.image = [UIImage imageNamed:@"添加按钮"];
        }
        
        UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconImage.right+5,40*i,100, 40)];
        keyLabel.text = @"服刑人员";
        keyLabel.textColor = UIColorFromRGB(102, 102, 102);
        keyLabel.font = FontOfSize(12);
        keyLabel.textAlignment  = NSTextAlignmentLeft;
        [_bgView addSubview:keyLabel];
        if (i==self.Prisons.count) {
            keyLabel.textColor = UIColorFromRGB(4, 47, 136);
            keyLabel.font = FontOfSize(14);
            keyLabel.text = @"绑定服刑人员";
        }
        UILabel *valueLab = [[UILabel alloc] initWithFrame:CGRectMake(_bgView.width-220, 40*i, 200,40)];
        valueLab.font = FontOfSize(12);
        valueLab.textColor = UIColorFromRGB(102, 102, 102);
        valueLab.textAlignment = NSTextAlignmentRight;
        [_bgView addSubview:valueLab];
        if (i<_Prisons.count) {
            MeetJails *meetJails = _Prisons[i];
            valueLab.text = meetJails.name;
        } else {
            valueLab.text = @"";
        }
    }
    
}

- (void)changAction:(UIButton *)sender {
    [self changALLIconImg];
    NSInteger tag = sender.tag;
    MeetJails *meetjails = _Prisons[tag-10];
    UIImageView *iconImg = [self viewWithTag:tag-10+100];
    [iconImg setImage:[UIImage imageNamed:@"已勾选"]];
    if (self.changeBlock) {
        self.changeBlock(meetjails);
    }
}

- (void)changALLIconImg {
    for (int i = 0;i<_Prisons.count; i++) {
        UIImageView *iconImg = [self viewWithTag:i+100];
        [iconImg setImage:[UIImage imageNamed:@"未选"]];
    }
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
