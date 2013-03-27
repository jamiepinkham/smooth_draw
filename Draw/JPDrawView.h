//
//  JPDrawView.h
//  Draw
//
//  Created by Jamie Pinkham on 3/27/13.
//  Copyright (c) 2013 Jamie Pinkham. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JPDrawViewType)
{
	JPDrawViewTypeControlPoints,
	JPDrawViewTypeSmoothPoints,
	JPDrawViewTypeQuadCurvePoints,
	JPDrawViewTypeAll,
};

@interface JPDrawView : UIView

@property (nonatomic, assign) JPDrawViewType drawType;

@end
