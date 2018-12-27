//
//  PrisonServiceTests.m
//  PrisonServiceTests
//
//  Created by calvin on 2018/4/2.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UIImage+Rename.h"


@interface PrisonServiceTests : XCTestCase

@end

@implementation PrisonServiceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}
//性能测试
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

//验证邮箱
- (void)testVerification_Postalcode{
//    UIImage *image = [UIImage R_imageNamed:@"广告图1111"];
//    //使用断言测试
//    XCTAssertNotNil(image,@"图片为nil不通过");
}



@end
