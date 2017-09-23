//
//  FeViewController.m
//  FilterMe-Texture
//
//  Created by Nghia Tran on 7/6/14.
//  Copyright (c) 2014 Fe. All rights reserved.
//

#import "FeViewController.h"
#import "FeCell.h"
#import "FeBasicAnimationBlock.h"

#import "GPUImage.h"
@interface FeViewController () <UITableViewDataSource, UITableViewDelegate>
{
    CGImageRef _previousImage;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) NSArray *arrTexture;

////////
-(void) initTableView;
-(void) initTexture;
@end

@implementation FeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self initTableView];
    
    [self initTexture];
    
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init
-(void) initTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
}
-(void) initTexture
{
    _arrTexture = @[@"texture_colorBurnBlend_1",
                    @"texture_linearBurnBlend_1",
                    @"texture_multiplyBlend_1",
                    @"texture_normalBlend_1",
                    @"texture_normalBlend_2",
                    @"texture_normalBlend_3",
                    @"texture_normalBlend_4",
                    @"texture_overlayBlend_1",
                    @"texture_overlayBlend_2",
                    @"texture_screenBlend_1"];
}

#pragma mark - Table View DataSouce
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Texture";
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrTexture.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"FeCell";
    FeCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    // Configure
    NSString *title = _arrTexture[indexPath.row];
    cell.titleLabel.text = title;
    
    return cell;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSString *filterName = _arrTexture[indexPath.row];
    
    // Filter
    GPUImageTwoInputFilter *filter;
    
    // Check blend mode
    // Color Burn
    NSRange rangeColorBurn = [filterName rangeOfString:@"colorBurnBlend"];
    if (rangeColorBurn.location != NSNotFound)
    {
        filter = [[GPUImageColorBurnBlendFilter alloc] init];
        [filter useNextFrameForImageCapture];
    }
    
    // LinearBurn
    NSRange rangeLinearBurn = [filterName rangeOfString:@"linearBurnBlend"];
    if (rangeLinearBurn.location != NSNotFound)
    {
        filter = [[GPUImageLinearBurnBlendFilter alloc] init];
        [filter useNextFrameForImageCapture];
    }
    
    // Multiply Blend
    NSRange rangeMultiplyBlend = [filterName rangeOfString:@"multiplyBlend"];
    if (rangeMultiplyBlend.location != NSNotFound)
    {
        filter = [[GPUImageMultiplyBlendFilter alloc] init];
        [filter useNextFrameForImageCapture];
    }
    
    // Normal blend
    NSRange rangeNormalBlend = [filterName rangeOfString:@"normalBlend"];
    if (rangeNormalBlend.location != NSNotFound)
    {
        filter = [[GPUImageNormalBlendFilter alloc] init];
        [filter useNextFrameForImageCapture];
    }
    
    // Overlay Blend
    NSRange rangeOverlayBlend = [filterName rangeOfString:@"overlayBlend"];
    if (rangeOverlayBlend.location != NSNotFound)
    {
        filter = [[GPUImageOverlayBlendFilter alloc] init];
        [filter useNextFrameForImageCapture];
    }
    
    // Screen Blend
    NSRange rangeScreenBlend = [filterName rangeOfString:@"screenBlend"];
    if (rangeScreenBlend.location != NSNotFound)
    {
        filter = [[GPUImageScreenBlendFilter alloc] init];
        [filter useNextFrameForImageCapture];
    }
    
    // GPUImage picture
    UIImage *imageOriginal = [UIImage imageNamed:@"originalPhoto.jpg"];
    UIImage *imageOverlay = [UIImage imageNamed:filterName];
    
    GPUImagePicture *picture_1 = [[GPUImagePicture alloc] initWithImage:imageOriginal];
    GPUImagePicture *picture_2 = [[GPUImagePicture alloc] initWithImage:imageOverlay];
    
    // Target
    [picture_1 addTarget:filter];
    [picture_1 processImage];
    
    [picture_2 addTarget:filter];
    [picture_2 processImage];
    
    //Blend
    UIImage *destinationPhoto = [filter imageFromCurrentFramebuffer];
    
    //_imageView.image = destinationPhoto;
    //_imageView.layer.content
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"contents"];
    fadeOutAnimation.fromValue = (__bridge id) _previousImage;
    fadeOutAnimation.toValue = (id) destinationPhoto.CGImage;
    fadeOutAnimation.duration = 1.0f;
    fadeOutAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    fadeOutAnimation.fillMode = kCAFillModeForwards;
    fadeOutAnimation.removedOnCompletion = NO;
    
    // Delegate
    FeBasicAnimationBlock *block = [[FeBasicAnimationBlock alloc] init];
    block.blockDidStart = ^{
        _tableView.userInteractionEnabled = NO;
    };
    block.blockDidStop = ^{
        _tableView.userInteractionEnabled = YES;
        _previousImage = destinationPhoto.CGImage;
    };
    
    // Set delegate
    fadeOutAnimation.delegate = block;
    
    [_imageView.layer addAnimation:fadeOutAnimation forKey:@"aa"];
}

@end
