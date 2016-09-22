//
//  ResizableUIView.m
//  Camera Test
//
//  Created by Kunal Thacker on 06/09/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

#import "ResizableUIView.h"

@implementation ResizableUIView

CGFloat kResizeThumbSize = 45.0f;

BOOL isResizingLR;
BOOL isResizingUL;
BOOL isResizingUR;
BOOL isResizingLL;
CGPoint touchStart;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // UITouch *touch = [[event allTouches] anyObject];
    touchStart = [[touches anyObject] locationInView:self];
    isResizingLR = (self.bounds.size.width - touchStart.x < kResizeThumbSize && self.bounds.size.height - touchStart.y < kResizeThumbSize);
    isResizingUL = (touchStart.x <kResizeThumbSize && touchStart.y <kResizeThumbSize);
    isResizingUR = (self.bounds.size.width-touchStart.x < kResizeThumbSize && touchStart.y<kResizeThumbSize);
    isResizingLL = (touchStart.x <kResizeThumbSize && self.bounds.size.height -touchStart.y <kResizeThumbSize);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([[event touchesForView:self] count] > 1) {
        NSLog(@"%lu active touches",[[event touchesForView:self] count]) ;
        NSLog(@"%@", [event touchesForView:self].allObjects.description);
        
    }
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    CGPoint previous = [[touches anyObject] previousLocationInView:self];

    CGFloat deltaWidth = touchPoint.x - previous.x;
    CGFloat deltaHeight = touchPoint.y - previous.y;

    // get the frame values so we can calculate changes below
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;

    if (isResizingLR) {
        self.frame = CGRectMake(x, y, touchPoint.x+deltaWidth, touchPoint.y+deltaWidth);
    } else if (isResizingUL) {
        self.frame = CGRectMake(x+deltaWidth, y+deltaHeight, width-deltaWidth, height-deltaHeight);
    } else if (isResizingUR) {
        self.frame = CGRectMake(x, y+deltaHeight, width+deltaWidth, height-deltaHeight);
    } else if (isResizingLL) {
        self.frame = CGRectMake(x+deltaWidth, y, width-deltaWidth, height+deltaHeight);
    } else {
        // not dragging from a corner -- move the view
        self.center = CGPointMake(self.center.x + touchPoint.x - touchStart.x,
                                  self.center.y + touchPoint.y - touchStart.y);
    }
}
@end
