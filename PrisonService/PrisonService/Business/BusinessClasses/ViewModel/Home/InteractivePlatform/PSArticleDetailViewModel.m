//
//  PSArticleDetailViewModel.m
//  PrisonService
//
//  Created by kky on 2019/9/17.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSArticleDetailViewModel.h"
#import "PSArtcleFindDetailRequest.h"
#import "PSArtcleFindDetailResponse.h"
#import "PSCollectArticleRequest.h"
#import "PSCancelCollectArticleRequest.h"
#import "PSArticlePraiseRequest.h"
#import "PSArticleDeletePraiseRequest.h"
#import "PSfamiliesAuthorRequest.h"
#import "PSfamiliesAuthorResponse.h"


@interface PSArticleDetailViewModel ()
@property (nonatomic, strong) PSArtcleFindDetailRequest *familyLogsRequest;
@property (nonatomic, strong) PSCollectArticleRequest *collectRequest;
@property (nonatomic, strong) PSCancelCollectArticleRequest *cancelCollectRequest;
@property (nonatomic, strong) PSArticlePraiseRequest *praiseRequest;
@property (nonatomic, strong) PSArticleDeletePraiseRequest *deletePraiseRequest;
@property (nonatomic, strong) PSfamiliesAuthorRequest *articleAuthorRequest;

@end

@implementation PSArticleDetailViewModel
- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}
//文章详情
- (void)loadArticleDetailCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    
    self.familyLogsRequest = [PSArtcleFindDetailRequest new];
    self.familyLogsRequest.id = [self.id integerValue];
    [self.familyLogsRequest send:^(PSRequest *request, PSResponse *response) {
        if (response.code == 200) {
            PSArtcleFindDetailResponse *logsResponse = (PSArtcleFindDetailResponse *)response;
            self.detailModel = logsResponse.detailModel;

            if (completedCallback) {
                completedCallback(response);
            }
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
                failedCallback(error);
            }
    }];
    
}
//收藏
- (void)collectArticleCompleted:(RequestDataCompleted)completedCallback
                         failed:(RequestDataFailed)failedCallback {
    self.collectRequest = [PSCollectArticleRequest new];
    self.collectRequest.articleId =  self.id;
    [self.collectRequest send:^(PSRequest *request, PSResponse *response) {
            if (completedCallback) {
                completedCallback(response);
            }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}
//取消收藏
- (void)cancelCollectArticleCompleted:(RequestDataCompleted)completedCallback
                               failed:(RequestDataFailed)failedCallback {
    
    self.cancelCollectRequest = [PSCancelCollectArticleRequest new];
    self.cancelCollectRequest.articleId =  self.id;
    [self.cancelCollectRequest send:^(PSRequest *request, PSResponse *response) {
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

//点赞
- (void)praiseArticleCompleted:(RequestDataCompleted)completedCallback
                        failed:(RequestDataFailed)failedCallback {
    self.praiseRequest = [PSArticlePraiseRequest new];
    self.praiseRequest.articleId =  self.id;
    [self.praiseRequest send:^(PSRequest *request, PSResponse *response) {
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

//取消点赞
- (void)deletePraiseArticleCompleted:(RequestDataCompleted)completedCallback
                              failed:(RequestDataFailed)failedCallback{
    self.deletePraiseRequest = [PSArticleDeletePraiseRequest new];
    self.deletePraiseRequest.articleId =  self.id;
    [self.deletePraiseRequest send:^(PSRequest *request, PSResponse *response) {
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
    
}

//获取是否能发文章权限
- (void)authorArticleCompleted:(RequestDataCompleted)completedCallback
                        failed:(RequestDataFailed)failedCallback {
//    {"msg":"[互动中心]检测账户是否禁用账户成功","code":200,"data":{"author":{"familyId":null,"disabledReason":null,"accountName":null,"isEnabled":1,"id":4,"pseudonym":"吴小可爱"}}}
    NSString*username=[NSString stringWithFormat:@"%@",[LXFileManager readUserDataForKey:@"username"]];
    self.articleAuthorRequest = [PSfamiliesAuthorRequest new];
    self.articleAuthorRequest.userName = username;
    self.articleAuthorRequest.type =  @"1";
    [self.articleAuthorRequest send:^(PSRequest *request, PSResponse *response) {
        if (!response) {
            PSPublicArticleModel *model = [[PSPublicArticleModel alloc] init];
            model.isEnabled = @"1";
            self.authorModel = model;
            completedCallback(response);
        }
        
        if (completedCallback) {
            if (response.code==200) {
                PSfamiliesAuthorResponse *AuthorResponse = (PSfamiliesAuthorResponse *)response;
                self.authorModel = AuthorResponse.author;
                completedCallback(response);
            }
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
    
}


//计算高度
-(CGFloat)calculationTextViewHeight:(UITextView *)textView {
    CGFloat height = 0;
    height = [self.detailModel.content boundingRectWithSize:CGSizeMake(200 - textView.textContainer.lineFragmentPadding * 2, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:textView.font} context:nil].size.height;//宽度减去左右两边的
    textView.bounds = CGRectMake(0, 0, 200, height);
    return height;
}

/**
 @method 获取指定宽度width,字体大小fontSize,字符串value的高度
 @param value 待计算的字符串
 @param fontSize 字体的大小
 @param Width 限制字符串显示区域的宽度
 @result float 返回的高度
 */
- (float)heightForString:(NSString *)value andWidth:(float)width{
    //获取当前文本的属性
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:value];
//    text.attributedText = attrStr;
    NSRange range = NSMakeRange(0, attrStr.length);
    // 获取该段attributedString的属性字典
    NSDictionary *dic = [attrStr attributesAtIndex:0 effectiveRange:&range];
    // 计算文本的大小
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 20;// 字体的行间距
    NSDictionary *attributes = @{
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    
    CGSize sizeToFit = [value boundingRectWithSize:CGSizeMake(width - 16.0, MAXFLOAT) // 用于计算文本绘制时占据的矩形块
                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading // 文本绘制时的附加选项
                                        attributes:attributes        // 文字的属性
                                           context:nil].size; // context上下文。包括一些信息，例如如何调整字间距以及缩放。该对象包含的信息将用于文本绘制。该参数可为nil
    return sizeToFit.height + 16.0;
}

/**
 @method 获取指定宽度width的字符串在UITextView上的高度
 @param textView 待计算的UITextView
 @param Width 限制字符串显示区域的宽度
 @result float 返回的高度
 */
- (float)heightForString1:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}

        


@end
