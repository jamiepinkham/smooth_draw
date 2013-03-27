//
//  JPViewController.m
//  Draw
//
//  Created by Jamie Pinkham on 3/27/13.
//  Copyright (c) 2013 Jamie Pinkham. All rights reserved.
//

#import "JPViewController.h"
#import "JPDrawView.h"

@interface JPViewController ()
@property (weak, nonatomic) IBOutlet JPDrawView *drawView;

@end

@implementation JPViewController


- (IBAction)drawStyleSegmentedControl:(id)sender
{
	UISegmentedControl *segControl = (UISegmentedControl *)sender;
	[self.drawView setDrawType:(JPDrawViewType)[segControl selectedSegmentIndex]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
