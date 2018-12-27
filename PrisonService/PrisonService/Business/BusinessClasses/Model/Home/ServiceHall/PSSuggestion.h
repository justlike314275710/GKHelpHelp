//
//  PSSuggestion.h
//  PrisonService
//
//  Created by calvin on 2018/4/27.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "JSONModel.h"

@protocol PSSuggestion <NSObject>

@end

@interface PSSuggestion : JSONModel

@property (nonatomic, strong) NSString<Optional> *id;
@property (nonatomic, strong) NSString<Optional> *title;
@property (nonatomic, strong) NSString<Optional> *contents;
@property (nonatomic, strong) NSString<Optional> *createdAt;
@property (nonatomic, strong) NSString<Optional> *name;
@property (nonatomic, strong) NSString<Optional> *imageUrls;
@property (nonatomic, strong) NSString<Optional> *typeName;
@property (nonatomic, strong) NSString<Optional> *desc;

//_jsonString = 0x00007fbbb61d58b0 @"{\"msg\":\"监狱长信箱分页查询成功\",\"code\":200,\"data\":{\"total\":1,\"mailBoxes\":[{\"id\":10,\"title\":\"主题:Wwwww\",\"contents\":\"Sawwwsawww\",\"createdAt\":\"2018-11-13 13:46:08\",\"name\":\"赵凯\",\"typeName\":\"其他问题\",\"desc\":null,\"imageUrls\":null,\"isReply\":1}]}}"
//}




@end
