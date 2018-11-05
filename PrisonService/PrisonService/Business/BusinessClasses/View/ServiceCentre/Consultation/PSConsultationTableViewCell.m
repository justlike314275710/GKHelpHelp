//
//  PSConsultationTableViewCell.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/29.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSConsultationTableViewCell.h"
#import "UITextView+Placeholder.h"
#import "PSConsultationViewModel.h"
@implementation PSConsultationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        CGFloat sidePidding=15;
        UIImageView *bgImageView = [UIImageView new];
        bgImageView.image = [[UIImage imageNamed:@"serviceHallServiceBg"] stretchImage];
        [self addSubview:bgImageView];
        [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(15);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.bottom.mas_equalTo(0);
        }];
        bgImageView.userInteractionEnabled=YES;
        
        UIButton*consulationButton=[[UIButton alloc]initWithFrame:CGRectMake(sidePidding, sidePidding, 100, 20)];
        [consulationButton setImage:[UIImage imageNamed:@"咨询分类"]forState:0];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"咨询分类(多选)"];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,4)];
        [str addAttribute:NSForegroundColorAttributeName value:AppBaseTextColor3 range:NSMakeRange(4,4)];
        [consulationButton setAttributedTitle:str forState:0];
        consulationButton.titleLabel.font=FontOfSize(12);
        [bgImageView addSubview:consulationButton];
        
        _choseButton=[[UIButton alloc]initWithFrame:CGRectMake(115, sidePidding, SCREEN_WIDTH-175, 20)];
        _choseButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
        [_choseButton setTitle:@"婚姻家庭▼" forState:0];
        [_choseButton setTitleColor:AppBaseTextColor1 forState:0];
        _choseButton.titleLabel.font=FontOfSize(11);
         [bgImageView addSubview:_choseButton];
       
        
        UIView*one_lineview=[[UIView alloc]initWithFrame:CGRectMake(sidePidding, 50, SCREEN_WIDTH-4*sidePidding, 1)];
        [bgImageView addSubview:one_lineview];
        one_lineview.backgroundColor=AppBaseLineColor;
        

        
        
        self.contentTextView = [[UITextView alloc]initWithFrame:CGRectMake(sidePidding, 50+sidePidding, SCREEN_WIDTH-4*sidePidding, 110)];
        self.contentTextView.font = FontOfSize(11);
        self.contentTextView.placeholder = @"为了便于得到律师专业的法律意见，请详细描述您的问题，您和律师的具体沟通过程中，请注意个人隐私，避免出现双方的真实姓名。";
        //self.contentTextView.delegate = self;
        [bgImageView addSubview:self.contentTextView];
        
        UIView*two_lineview=[[UIView alloc]initWithFrame:CGRectMake(sidePidding, 175, SCREEN_WIDTH-4*sidePidding, 1)];
        [bgImageView addSubview:two_lineview];
        two_lineview.backgroundColor=AppBaseLineColor;
        
        CGFloat buttonSide=(SCREEN_WIDTH-90)/4;
        self.albumButton=[[UIButton alloc]initWithFrame:CGRectMake(buttonSide, 185, 20, 17)];
        [self.albumButton setImage:[UIImage imageNamed:@"图片图标"] forState:0];
        [bgImageView addSubview:self.albumButton];
        
        self.cameraButton=[[UIButton alloc]initWithFrame:CGRectMake(2*buttonSide+20, 185, 20, 17)];
        [self.cameraButton setImage:[UIImage imageNamed:@"拍照"] forState:0];
        [bgImageView addSubview:self.cameraButton];
        
        self.fileButton=[[UIButton alloc]initWithFrame:CGRectMake(3*buttonSide+40, 185, 20, 17)];
        [self.fileButton setImage:[UIImage imageNamed:@"文件"] forState:0];
        [bgImageView addSubview:self.fileButton];
        
        UIView*three_lineview=[[UIView alloc]initWithFrame:CGRectMake(sidePidding, 210, SCREEN_WIDTH-4*sidePidding, 1)];
        [bgImageView addSubview:three_lineview];
        three_lineview.backgroundColor=AppBaseLineColor;
//        (SCREEN_WIDTH-130)/4
        self.pickerV = [LLImagePickerView ImagePickerViewWithFrame:CGRectMake(5, 211, SCREEN_WIDTH-40, ((SCREEN_WIDTH-40)/4-5)*2 ) CountOfRow:4];
        [bgImageView addSubview:_pickerV];
        _pickerV.type = LLImageTypePhotoAndCamera;
        _pickerV.maxImageSelected = 4;
        _pickerV.allowPickingVideo = YES;


        
    }
    return self;
}





@end
