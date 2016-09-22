//
//  UIImage+ImageCategory.m
//  Camera Test
//
//  Created by Kunal Thacker on 11/09/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

#import "UIImage+ImageCategory.h"

@implementation UIImage (ImageCategory)
- (UIImage *)drawImage:(UIImage *)inputImage inRect:(CGRect)frame {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    [self drawInRect:CGRectMake(0.0, 0.0, self.size.width, self.size.height)];
    [inputImage drawInRect:frame];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
