//
//  JPDrawView.m
//  Draw
//
//  Created by Jamie Pinkham on 3/27/13.
//  Copyright (c) 2013 Jamie Pinkham. All rights reserved.
//

#import "JPDrawView.h"

CGFloat distance(CGPoint from, CGPoint to)
{
	CGFloat x = from.x-to.x;
	CGFloat y = from.y-to.y;
	return (x*x) + (y*y);
}

@interface JPDrawView ()

@property (nonatomic, strong) NSMutableArray *touchPoints;
@property (nonatomic, strong) NSArray *drawPoints;

@end

@implementation JPDrawView

static NSUInteger kSmoothLength = 4;
CGFloat kMinMoveDist = 8.0f;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(ctx);
	[[UIColor whiteColor] set];
	UIRectFill(self.bounds);
  	CGPoint p0 = [self.drawPoints[0] CGPointValue];
  	CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
  	CGContextBeginPath(ctx);
 	CGContextMoveToPoint(ctx, p0.x, p0.y);
  	for(NSUInteger i = 1; i < self.drawPoints.count; ++i)
	{
    	NSValue *p = self.drawPoints[i];
		CGPoint point = [p CGPointValue];
		CGContextAddLineToPoint(ctx, point.x, point.y);
  	}
 	CGContextStrokePath(ctx);
	CGContextRestoreGState(ctx);
}


-(NSArray *)smoothPoints:(NSArray *)points
{
	NSMutableArray *returnPoints = [NSMutableArray arrayWithArray:points];
	for(NSUInteger i = 0; i < kSmoothLength; i++)
	{
		NSUInteger j = points.count - i - 2;
		NSValue *point0Value = points[j];
		NSValue *point1Value = points[j+1];
		CGPoint p0 = [point0Value CGPointValue];
		CGPoint p1 = [point1Value CGPointValue];
		CGFloat a = 0.2;
		CGPoint point = { .x = p0.x * (1-a) + p1.x * a, .y = p0.y * (1-a) + p1.y * a};
		returnPoints[j] = [NSValue valueWithCGPoint:point];
	}
	return returnPoints;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.touchPoints = [NSMutableArray array];
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	for(NSUInteger i = 0; i < kSmoothLength+1; i++)
	{
		[self.touchPoints addObject:[NSValue valueWithCGPoint:point]];
	}
	[self setNeedsDisplay];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	CGPoint last = [[self.touchPoints lastObject] CGPointValue];
	if(distance(point, last) > kMinMoveDist)
	{
		[self.touchPoints addObject:[NSValue valueWithCGPoint:point]];
		self.drawPoints = [self smoothPoints:self.touchPoints];
	}
	[self setNeedsDisplay];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}


@end
