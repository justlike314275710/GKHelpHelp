//
//  PSFamily.m
//  PrisonService
//
//  Created by calvin on 2018/4/20.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSFamily.h"

@implementation PSFamily
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.phone = [aDecoder decodeObjectForKey:@"phone"];
        self.avatarUrl = [aDecoder decodeObjectForKey:@"avatarUrl"];
        self.idCardFront = [aDecoder decodeObjectForKey:@"idCardFront"];
        self.idCardBack = [aDecoder decodeObjectForKey:@"idCardBack"];
        self.balance = [aDecoder decodeFloatForKey:@"balance"];
        self.isNoticed=[aDecoder decodeObjectForKey:@"isNoticed"];
        self.openId=[aDecoder decodeObjectForKey:@"openId"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.phone forKey:@"phone"];
    [aCoder encodeObject:self.avatarUrl forKey:@"avatarUrl"];
    [aCoder encodeObject:self.idCardFront forKey:@"idCardFront"];
    [aCoder encodeObject:self.idCardBack forKey:@"idCardBack"];
    [aCoder encodeObject:self.isNoticed forKey:@"isNoticed"];
    [aCoder encodeFloat:self.balance forKey:@"balance"];
    [aCoder encodeObject:self.openId forKey:@"openId"];

}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return [propertyName isEqualToString:@"balance"];
}

@end
