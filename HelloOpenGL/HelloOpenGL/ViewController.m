//
//  ViewController.m
//  HelloOpenGL
//
//  Created by qi on 30/11/2017.
//  Copyright © 2017 tvu. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLView.h"

@interface ViewController ()
@property (nonatomic,strong) OpenGLView *glView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _glView = [[OpenGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_glView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
