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

CGPoint midPoint(CGPoint p1, CGPoint p2)
{
	
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
	
}

@interface JPDrawView ()

@property (nonatomic, strong) NSMutableArray *touchPoints;
@property (nonatomic, strong) NSArray *drawPoints;
@property (nonatomic, strong) UIBezierPath *currentCurvePath;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) CGPoint currentPoint;

@end

@implementation JPDrawView

static NSUInteger kSmoothLength = 8;
CGFloat kMinMoveDist = 8.0f;
CGPoint pts[5];

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.currentCurvePath = [UIBezierPath bezierPath];
		self.multipleTouchEnabled = NO;
		self.touchPoints = [NSMutableArray new];
		self.drawPoints = [NSMutableArray new];
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
		self.currentCurvePath = [UIBezierPath bezierPath];
		self.multipleTouchEnabled = NO;
		self.touchPoints = [NSMutableArray new];
		self.drawPoints = [NSMutableArray new];
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
	if(self.drawType == JPDrawViewTypeAll || self.drawType == JPDrawViewTypeControlPoints)
	{
		[self.currentCurvePath setLineWidth:12.0];
		CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
		[self.currentCurvePath stroke];
	}
	if(self.drawType == JPDrawViewTypeAll || self.drawType == JPDrawViewTypeSmoothPoints)
	{
		if(self.drawPoints.count)
		{
			CGContextSetStrokeColorWithColor(ctx, [UIColor blueColor].CGColor);
			CGContextSetLineWidth(ctx, 7.0);
			CGContextSetLineCap(ctx, kCGLineCapRound);
			
			CGContextBeginPath(ctx);
			CGPoint p0 = [self.drawPoints[0] CGPointValue];
			CGContextMoveToPoint(ctx, p0.x, p0.y);
			for(NSUInteger i = 1; i < self.drawPoints.count; ++i)
			{
				NSValue *p = self.drawPoints[i];
				CGPoint point = [p CGPointValue];
				CGContextAddLineToPoint(ctx, point.x, point.y);
			}
			CGContextStrokePath(ctx);
		}
	}
	if(self.drawType == JPDrawViewTypeAll || self.drawType == JPDrawViewTypeQuadCurvePoints)
	{
		if(self.touchPoints.count > 2)
		{
			BOOL shouldStroke = NO;
			for(NSUInteger i = 0; i < self.touchPoints.count; i++)
			{
				CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
				CGContextSetLineWidth(ctx, 3.0f);
				if((i + 2) < self.touchPoints.count - 1)
				{
					CGPoint first = [self.touchPoints[i] CGPointValue];
					CGPoint next = [self.touchPoints[i+1] CGPointValue];
					CGPoint last = [self.touchPoints[i+2] CGPointValue];
					CGPoint mid1 = midPoint(first, next);
					CGPoint mid2 = midPoint(next, last);
					
					if(!(CGPointEqualToPoint(mid1, CGPointZero) || CGPointEqualToPoint(mid1, CGPointZero)))
					{
						CGContextMoveToPoint(ctx, mid1.x, mid1.y);
						// Use QuadCurve is the key
						CGContextAddQuadCurveToPoint(ctx, next.x, next.y, mid2.x, mid2.y);
						shouldStroke = YES;
					}
				}
			}
			if(shouldStroke)
			{
				CGContextStrokePath(ctx);
			}
		}
	}
	
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
	[self.currentCurvePath removeAllPoints];
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	self.count = 0;
	pts[0] = point;
	
	self.touchPoints = [NSMutableArray new];
	for(NSUInteger i = 0; i < kSmoothLength+1; i++)
	{
		[self.touchPoints addObject:[NSValue valueWithCGPoint:point]];
	}

	self.currentPoint = point;
	[self setNeedsDisplay];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	self.count++;
	pts[self.count] = point;
	if (self.count == 4)
    {
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
        [self.currentCurvePath moveToPoint:pts[0]];
        [self.currentCurvePath addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
        [self setNeedsDisplay];
        // replace points and get ready to handle the next segment
        pts[0] = pts[3];
        pts[1] = pts[4];
        self.count = 1;
    }
	CGPoint last = [[self.touchPoints lastObject] CGPointValue];
	if(distance(point, last) > kMinMoveDist)
	{
		[self.touchPoints addObject:[NSValue valueWithCGPoint:point]];
		self.drawPoints = [self smoothPoints:self.touchPoints];
	}
	
//	self.previousPoint2 = self.previousPoint1;
//    self.previousPoint1 = [touch previousLocationInView:self];
    self.currentPoint = [touch locationInView:self];
	
//	self.mid1 = midPoint(self.previousPoint1, self.previousPoint2);
//	self.mid2 = midPoint(self.currentPoint, self.previousPoint1);
	
	[self setNeedsDisplay];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//	[self.currentPath removeAllPoints];
	[self setNeedsDisplay];
}


@end
