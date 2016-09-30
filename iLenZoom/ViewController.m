//
//  ViewController.m
//  iLenZoom
//
//  Created by Bui Duc Khanh on 9/29/16.
//  Copyright © 2016 Bui Duc Khanh. All rights reserved.
//

#import "ViewController.h"


@interface ViewController () <UIGestureRecognizerDelegate>

@property UIImageView *imageView;

@property CGFloat shapeRadius;
@property CGPoint shapeCenter;
@property CGFloat shapeRotation;

@property (nonatomic, weak) CAShapeLayer *maskLayer;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Khởi tạo ảnh background trước
    self.imageView = [UIImageView new];
    self.imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.imageView setImage:[UIImage imageNamed:@"bg.png"]];
    self.imageView.userInteractionEnabled = YES;                // Khởi tạo tương tác với ảnh
    [self.view addSubview:self.imageView];
    
    
    // Tạo một layer che ảnh background bẳng mask của layer
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    self.imageView.layer.mask = maskLayer;
    self.maskLayer = maskLayer;
    
    self.shapeRotation = 0;
    
    // Khởi tạo khung nhìn bằng cách vẽ mask ( tạo path bao lấy layer )
    [self updateViewPathAtLocation:CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0) radius:self.view.bounds.size.width * 0.30 rotation:0];
    
    
    // Tạo và quản lý sự kiện pan
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.imageView addGestureRecognizer:pan];
    
    
    // Tạo và quản lý sự kiện pinch
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
    
    // Tạo và quản lý sự kiện Rotation
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    rotation.delegate = self;
    [self.view addGestureRecognizer:rotation];
}


// Vẽ hình cho mask layer để hiển thị
- (void)updateViewPathAtLocation:(CGPoint)location radius:(CGFloat)radius rotation:(CGFloat) rotation
{
    self.shapeCenter = location;
    self.shapeRadius = radius;
    self.shapeRotation += rotation;
    
    /*
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:self.circleCenter
                    radius:self.circleRadius
                startAngle:0.0
                  endAngle:M_PI * 2.0
                 clockwise:YES];
     */
    
    CGRect rect= CGRectMake(self.shapeCenter.x - self.shapeRadius, self.shapeCenter.y - self.shapeRadius * 0.7, self.shapeRadius * 2.0, self.shapeRadius * 1.4);
    
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    // Rotate path: bản thân path là 1 tập hợp các điểm nếu chỉ gọi rotate nó sẽ quay theo anchor point origin
    // Ở đây ta thực hiện : tịnh tiến đến tâm của oval
    // Rotate
    // Tịnh tiến trở lại điểm gốc toạ độ
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, self.shapeCenter.x, self.shapeCenter.y);
    transform = CGAffineTransformRotate(transform, self.shapeRotation);
    transform = CGAffineTransformTranslate(transform, -self.shapeCenter.x, -self.shapeCenter.y);
    
    [path applyTransform:transform];
    
    
    self.maskLayer.path = [path CGPath];

}



#pragma mark - Gesture recognizers

// Xử lý Pan dời tâm của hình
- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    static CGPoint oldCenter;
    CGPoint tranlation = [gesture translationInView:gesture.view];
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        oldCenter = self.shapeCenter;
    }
    
    CGPoint newCenter = CGPointMake(oldCenter.x + tranlation.x, oldCenter.y + tranlation.y);
    
    [self updateViewPathAtLocation:newCenter radius:self.shapeRadius rotation:0];
}


// Xử lý pinch tăng giảm bán kính
- (void)handlePinch:(UIPinchGestureRecognizer *)gesture
{
    static CGFloat oldRadius;
    CGFloat scale = [gesture scale];
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        oldRadius = self.shapeRadius;
    }
    
    CGFloat newRadius = oldRadius * scale;
    
    [self updateViewPathAtLocation:self.shapeCenter radius:newRadius rotation:0];
}


// Xoay khi rotate
- (void) handleRotation: (UIRotationGestureRecognizer*) gesture{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        
        [self updateViewPathAtLocation:self.shapeCenter radius:self.shapeRadius rotation:gesture.rotation];
        
        gesture.rotation = 0.0;
    }
}


#pragma mark - UIGestureRecognizerDelegate

// Nhận diện đồng thời tất cả các sự kiện ở đây căn bản không có conflict
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
@end
