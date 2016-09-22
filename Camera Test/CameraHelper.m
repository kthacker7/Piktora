//
//  CameraHelper.m
//  Camera Test
//
//  Created by Kunal Thacker on 10/09/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h> 
#import <QuartzCore/QuartzCore.h>

@interface CameraHelper : NSObject

- (UIImage *) replaceColor: (UIColor*)color inImage:(UIImage *) image withTolerance: (float) tolerance;
- (UIImage *) imageWithView:(UIView *)view;
- (UIImage *)cropImage:(UIImage *)image toFrame:(CGRect)frame withScale: (CGFloat) scale withOrientatio: (UIImageOrientation)orientation;

@end

@implementation CameraHelper
- (UIImage*) replaceColor:(UIColor*)color inImage:(UIImage*)image withTolerance:(float)tolerance {
    CGImageRef imageRef = [image CGImage];

    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    NSUInteger bitmapByteCount = bytesPerRow * height;

    unsigned char *rawData = (unsigned char*) calloc(bitmapByteCount, sizeof(unsigned char));

    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);

    CGColorRef cgColor = [color CGColor];
    const CGFloat *components = CGColorGetComponents(cgColor);
    float r = components[0];
    float g = components[1];
    float b = components[2];
    //float a = components[3]; // not needed

    r = r * 255.0;
    g = g * 255.0;
    b = b * 255.0;

    const float redRange[2] = {
        MAX(r - (tolerance / 2.0), 0.0),
        MIN(r + (tolerance / 2.0), 255.0)
    };

    const float greenRange[2] = {
        MAX(g - (tolerance / 2.0), 0.0),
        MIN(g + (tolerance / 2.0), 255.0)
    };

    const float blueRange[2] = {
        MAX(b - (tolerance / 2.0), 0.0),
        MIN(b + (tolerance / 2.0), 255.0)
    };

    int byteIndex = 0;

    while (byteIndex < bitmapByteCount) {
        unsigned char red   = rawData[byteIndex];
        unsigned char green = rawData[byteIndex + 1];
        unsigned char blue  = rawData[byteIndex + 2];

        if (((red >= redRange[0]) && (red <= redRange[1])) &&
            ((green >= greenRange[0]) && (green <= greenRange[1])) &&
            ((blue >= blueRange[0]) && (blue <= blueRange[1]))) {
            // make the pixel transparent
            //
            rawData[byteIndex] = 0;
            rawData[byteIndex + 1] = 0;
            rawData[byteIndex + 2] = 0;
            rawData[byteIndex + 3] = 0;
        }

        byteIndex += 4;
    }

    CGImageRef imgref = CGBitmapContextCreateImage(context);
    UIImage *result = [UIImage imageWithCGImage:imgref];

    CGImageRelease(imgref);
    CGContextRelease(context);
    free(rawData);
    
    return result;
}

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return img;
}

- (UIImage *)cropImage:(UIImage *)image toFrame:(CGRect)frame withScale: (CGFloat) scale withOrientatio: (UIImageOrientation)orientation {

    frame = CGRectMake(frame.origin.x * scale,
                      frame.origin.y * scale,
                      frame.size.width * scale,
                      frame.size.height * scale);

    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, frame);
    UIImage *result = [UIImage imageWithCGImage: imageRef
                                          scale: scale
                                    orientation: orientation];
    CGImageRelease(imageRef);
    return result;
}



@end
