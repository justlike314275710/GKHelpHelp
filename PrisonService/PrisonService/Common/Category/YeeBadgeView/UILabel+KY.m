//
//  UILabel+KY.m
//  DAudiobook
//
//  Created by kky on 2019/10/12.
//  Copyright © 2019年 liujiliu. All rights reserved.
//

#import "UILabel+KY.h"
#import <objc/runtime.h>
#import <CoreText/CoreText.h>


@implementation UILabel (KY)
static const char *characterSpaceKey = "characterSpaceKey";
static const char *lineSpaceKey = "lineSpaceKey";

- (void)setCharacterSpace:(NSString *)characterSpace{

        [self willChangeValueForKey:@"characterSpace"]; // KVO
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.text];
        [attributedString addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0,self.text.length)];
        if ([characterSpace integerValue]>0) {
            long number = [characterSpace integerValue];
            CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
            [attributedString addAttribute:(id)kCTKernAttributeName value:(__bridge id)num range:NSMakeRange(0,[attributedString length])];
            CFRelease(num);
        }
        self.attributedText = attributedString;
        
        objc_setAssociatedObject(self, &characterSpaceKey,
                                 characterSpace, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"characterSpace"]; // KVO
}

-(void)setLineSpace:(NSString *)lineSpace {
        [self willChangeValueForKey:@"lineSpace"]; // KVO
        objc_setAssociatedObject(self, &lineSpaceKey,
                                 lineSpace, OBJC_ASSOCIATION_ASSIGN);
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.text];
        [attributedString addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0,self.text.length)];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        // 行间距
        if([lineSpace integerValue] > 0){
            [paragraphStyle setLineSpacing:[lineSpace integerValue]];
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,self.text.length)];
        }
        self.attributedText = attributedString;
        
        [self didChangeValueForKey:@"lineSpace"]; // KVO
}


-(NSString *)characterSpace{
    return objc_getAssociatedObject(self, &characterSpaceKey);
}

-(NSString *)lineSpace{
    return objc_getAssociatedObject(self, &lineSpaceKey);
}

- (CGFloat)getLableHeightWithMaxWidth:(CGFloat)maxWidth{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.text];
    [attributedString addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0,self.text.length)];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    // 行间距
    if(self.lineSpace > 0){
        
        [paragraphStyle setLineSpacing:[self.lineSpace integerValue]];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,self.text.length)];
    }
    
    // 字间距
    if(self.characterSpace > 0){
        
        long number = [self.characterSpace integerValue];
        CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
        [attributedString addAttribute:(id)kCTKernAttributeName value:(__bridge id)num range:NSMakeRange(0,[attributedString length])];
        
        CFRelease(num);
    }
        
    self.attributedText = attributedString;
    
    CGRect rect = [attributedString boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    // 向上取整，防止画UI时lab的高度取整
    return ceil(rect.size.height);
}

@end
