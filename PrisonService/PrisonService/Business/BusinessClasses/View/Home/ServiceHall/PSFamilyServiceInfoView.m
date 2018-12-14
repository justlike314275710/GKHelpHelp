//
//  PSFamilyServiceInfoView.m
//  PrisonService
//
//  Created by calvin on 2018/4/13.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSFamilyServiceInfoView.h"
#import "PSFamilyServiceInfoCell.h"

@interface PSFamilyServiceInfoView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *infoTableView;

@end

@implementation PSFamilyServiceInfoView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *headImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"serviceHallDefaultHead"]];
        [self addSubview:headImageView];
        [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(15);
            make.centerX.mas_equalTo(self);
            make.size.mas_equalTo(headImageView.frame.size);
        }];
        _prisonerLabel = [UILabel new];
        _prisonerLabel.font = AppBaseTextFont2;
        _prisonerLabel.textColor = UIColorFromHexadecimalRGB(0x333333);
        _prisonerLabel.textAlignment = NSTextAlignmentCenter;
        _prisonerLabel.text = @"测试名字(10001)";
        [self addSubview:_prisonerLabel];
        [_prisonerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.top.mas_equalTo(headImageView.mas_bottom);
            make.height.mas_equalTo(15);
        }];
        self.infoTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.infoTableView.backgroundColor = [UIColor clearColor];
        self.infoTableView.dataSource = self;
        self.infoTableView.delegate = self;
        self.infoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.infoTableView registerClass:[PSFamilyServiceInfoCell class] forCellReuseIdentifier:@"PSFamilyServiceInfoCell"];
        [self addSubview:self.infoTableView];
        [self.infoTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(self.prisonerLabel.mas_bottom).offset(10);
            make.bottom.mas_equalTo(-10);
        }];
    }
    return self;
}

- (void)setPrisonerName:(NSString *)prisonerName {
    [self.infoTableView reloadData];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (self.infoRows) {
        rows = self.infoRows();
    }
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 23;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSFamilyServiceInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PSFamilyServiceInfoCell"];
    if (self.iconNameOfRow) {
        cell.imageView.image = [UIImage imageNamed:self.iconNameOfRow(indexPath.row)];
    }
    if (self.titleTextOfRow) {
        cell.textLabel.text = self.titleTextOfRow(indexPath.row);
    }
    if (self.detailTextOfRow) {
        cell.detailTextLabel.text = self.detailTextOfRow(indexPath.row);
        
    }
    return cell;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
