//
//  WXIPhotoTitleCell.m
//  WXILayoutImage
//
//  Created by wuxi on 16/8/26.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import "WXIPhotoTitleCell.h"
#import "Masonry.h"

@implementation WXIPhotoTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.previewImageView = [[UIImageView alloc] init];
        self.previewImageView.contentMode = UIViewContentModeScaleToFill;
        self.previewImageView.clipsToBounds = YES;
        [self addSubview:self.previewImageView];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:self.nameLabel];
        
        self.numberLabel = [[UILabel alloc] init];
        self.numberLabel.textColor = [UIColor lightGrayColor];
        self.numberLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.numberLabel];
        
        __weak id weakSelf = self;
        [self.previewImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.and.bottom.equalTo(weakSelf);
            make.right.equalTo(_nameLabel.mas_left).with.offset(-15);
            make.height.equalTo(weakSelf);
            make.width.equalTo(self.previewImageView.mas_height);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_previewImageView.mas_right).with.offset(15);
            make.top.and.bottom.equalTo(weakSelf);
            make.width.mas_equalTo(180);
        }];
        
        [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.and.bottom.equalTo(weakSelf);
            make.height.equalTo(weakSelf);
            make.width.mas_equalTo(50);
        }];
    }
    return self;
}
@end
