//
//  PSPublishArticleViewModel.m
//  PrisonService
//
//  Created by kky on 2019/9/18.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSPublishArticleViewModel.h"
#import "PSArticleFindPenNameResponse.h"
#import "PSPublishFamilyArticleRequest.h"
#import "PSJSONTool.h"
#import "NSString+emoji.h" 
@interface PSPublishArticleViewModel ()
@property(nonatomic,strong)PSArticleFindPenNameRequest *articleFindPenNameRequest;
@property(nonatomic,strong)PSPublishFamilyArticleRequest *publishFamilyArticleRequest;

@end

@implementation PSPublishArticleViewModel
- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

//查找笔名
//{"msg":"获取笔名成功","code":200,"data":{"familyId":null,"disabledReason":null,"accountName":null,"isEnabled":1,"id":4,"pseudonym":"吴小可爱"}}
- (void)findPenNameCompleted:(RequestDataCompleted)completedCallback
                      failed:(RequestDataFailed)failedCallback{
    
    self.articleFindPenNameRequest = [PSArticleFindPenNameRequest new];
    [self.articleFindPenNameRequest send:^(PSRequest *request, PSResponse *response) {
        if (response.code == 200) {
            if (completedCallback) {
                PSArticleFindPenNameResponse *findPenNameResponse = (PSArticleFindPenNameResponse *)response;
                self.model = findPenNameResponse.publicArticleModel;
                completedCallback(response);
            }
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
    
}

//发布文章
- (void)publishArticleCompleted:(RequestDataCompleted)completedCallback
                         failed:(RequestDataFailed)failedCallback {
    
    self.publishFamilyArticleRequest = [PSPublishFamilyArticleRequest new];
    self.publishFamilyArticleRequest.id = self.type==PSPublishArticle?@"":self.id;
    self.publishFamilyArticleRequest.title = self.title;
    self.publishFamilyArticleRequest.content = self.content;
    self.publishFamilyArticleRequest.articleType = self.articleType; //文章类型(1为互动文章，2为连载小说)
    self.publishFamilyArticleRequest.penName = self.penName;
    [self.publishFamilyArticleRequest send:^(PSRequest *request, PSResponse *response) {
//        {"msg":"存在敏感字","code":1586,"data":{"words":["测试","刘德华"]}}
        if (response.code==1586) {
            NSString *dataString = [response description];
            NSDictionary *responseDic = [PSJSONTool dictionaryWithJsonString:dataString];
            NSDictionary *dic = [responseDic valueForKey:@"data"];
            self.words =  [dic valueForKey:@"words"];
            NSLog(@"%@",_words);
        }
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
    
}

- (void)checkDataWithCallback:(CheckDataCallback)callback {
    if (self.penName.length<=0&&self.title.length<=0) {
        callback(NO,@"请输入作者笔名/标题");
        return;
    }
    if (self.penName.length<=0)
    {
        callback(NO,@"请输入作者笔名");
    } else if (self.penName.length>6)
    {
        callback(NO,@"作者笔名不能超过6个字");
    } else if (self.title.length<=0)
    {
        callback(NO,@"请输入文章标题");
    } else if (self.title.length>20)
    {
        callback(NO,@"文章标题不能超过20个字");
    } else if (self.content.length<100)
    {
        callback(NO,@"文章内容字数限制为100-20000");
    } else if (self.content.length>20000)
    {
        callback(NO,@"文章内容字数限制为100-20000");
    } else if ([NSString hasEmoji:self.content]||[NSString stringContainsEmoji:self.content])
    {
        callback(NO,@"文章内容不能包含表情符号");
    }else if ([NSString hasEmoji:self.title]||[NSString stringContainsEmoji:self.title])
    {
        callback(NO,@"文章标题不能包含表情符号");
    }else if ([NSString hasEmoji:self.penName]||[NSString stringContainsEmoji:self.penName])
    {
        callback(NO,@"笔名不能包含表情符号");
    }
    else {
        callback(YES,nil);
    }
    
}

#pragma mark - 获取这个字符串中的所有xxx的所在的index
- (NSMutableArray *)getRangeStr:(NSString *)text findText:(NSString *)findText
{
    
    NSMutableArray *arrayRanges = [NSMutableArray arrayWithCapacity:3];
    
    if (findText == nil && [findText isEqualToString:@""])
    {
        
        return nil;
        
    }
    
    NSRange rang = [text rangeOfString:findText]; //获取第一次出现的range
    
    if (rang.location != NSNotFound && rang.length != 0)
    {
        
        [arrayRanges addObject:[NSNumber numberWithInteger:rang.location]];//将第一次的加入到数组中
        
        NSRange rang1 = {0,0};
        
        NSInteger location = 0;
        
        NSInteger length = 0;
        
        for (int i = 0;; i++)
        {
            
            if (0 == i)
            {//去掉这个xxx
                
                location = rang.location + rang.length;
                
                length = text.length - rang.location - rang.length;
                
                rang1 = NSMakeRange(location, length);
                
            }
            else
            {
                
                location = rang1.location + rang1.length;
                
                length = text.length - rang1.location - rang1.length;
                
                rang1 = NSMakeRange(location, length);
                
            }
            
            //在一个range范围内查找另一个字符串的range
            
            rang1 = [text rangeOfString:findText options:NSCaseInsensitiveSearch range:rang1];
            
            if (rang1.location == NSNotFound && rang1.length == 0)
            {
                
                break;
                
            }
            else//添加符合条件的location进数组
                
                [arrayRanges addObject:[NSNumber numberWithInteger:rang1.location]];
            
        }
        
        return arrayRanges;
        
    }
    
    return nil;
    
}


@end
