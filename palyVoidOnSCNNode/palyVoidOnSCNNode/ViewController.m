//
//  ViewController.m
//  palyVoidOnSCNNode
//
//  Created by LJP on 2018/5/3.
//  Copyright © 2018年 ljp. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <ARSCNViewDelegate>

@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;

/**
 *  添加模型按钮
 */
@property (nonatomic, strong) UIButton * addNodeBtn;

/**
 *  把视频加在模型上的按钮
 */
@property (nonatomic, strong) UIButton * playVoidBtn;

/**
 *  播放器对象
 */
@property (nonatomic, strong) AVPlayer *player;

/**
 *  展示的模型
 */
@property (nonatomic, strong) SCNNode *showNode;

/**
 *  调节进度的滑竿
 */
@property (nonatomic, strong) UISlider *slider;

/**
 *  调节的时间
 */
@property (nonatomic, assign) CMTime chaseTime;

@end

    
@implementation ViewController

#pragma mark ========================= 生命周期 =========================
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];

    [self.sceneView.session runWithConfiguration:configuration];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.sceneView.session pause];
}


#pragma mark ========================= 初始化方法 ========================
- (void)initUI {
    
    self.sceneView.delegate = self;
    SCNScene *scene = [SCNScene new];
    self.sceneView.scene = scene;
    
    [self.sceneView addSubview:self.addNodeBtn];
    [self.sceneView addSubview:self.playVoidBtn];
    [self.sceneView addSubview:self.slider];

}


#pragma mark ========================= 私有方法 ==========================
- (void)trySeekToChaseTime{
    
    if (_player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        
        [self actuallySeekToTime];
        
    }
    
}

- (void)actuallySeekToTime {
    
    CMTime seekTimeInProgress = self.chaseTime;

    [self.player seekToTime:seekTimeInProgress
            toleranceBefore:kCMTimeZero
            toleranceAfter :kCMTimeZero
          completionHandler:^(BOOL finished) {
        
//        [self.player play]; 打开就会自动播放了

    }];
    
}

#pragma mark ========================= 事件处理 ==========================
- (void)clickAddNodeBtn {
    
    [self.sceneView.scene.rootNode addChildNode:self.showNode];
    
}

- (void)clickPlayVoidBtn {
   
    SCNMaterial * material = [[SCNMaterial alloc]init];
    
    material.diffuse.contents = self.player;
    
    self.showNode.geometry.materials = @[material];
    
    [self.player play];
    
}

- (void)playerProcess:(UISlider *)slider{

    NSString * urlStr = [[NSBundle mainBundle]pathForResource:@"movie.MP4" ofType:nil];
    
    NSURL * url = [NSURL fileURLWithPath:urlStr];
    
    AVAsset * asset = [AVAsset assetWithURL:url];
    
    float totalTime = CMTimeGetSeconds(asset.duration);
    
    [self.player pause];
    
    CMTime newChaseTime = CMTimeMake(totalTime * slider.value * asset.duration.timescale, asset.duration.timescale);
    
    self.chaseTime = newChaseTime;
    
    [self actuallySeekToTime];

}


#pragma mark ========================= 代理方法 ==========================


#pragma mark ========================= 访问器方法 =========================
- (UIButton *)addNodeBtn {
    if (_addNodeBtn == nil) {
        _addNodeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _addNodeBtn.frame = CGRectMake(self.view.frame.size.width/4-40, self.view.frame.size.height-160, 80, 48);
        [_addNodeBtn setTitle:@"添加模型" forState:0];
        [_addNodeBtn addTarget:self action:@selector(clickAddNodeBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addNodeBtn;
}

- (UIButton *)playVoidBtn {
    if (_playVoidBtn == nil) {
        _playVoidBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _playVoidBtn.frame = CGRectMake(self.view.frame.size.width/4*3-40, self.view.frame.size.height-160, 80, 48);
        [_playVoidBtn setTitle:@"播放视频" forState:0];
        [_playVoidBtn addTarget:self action:@selector(clickPlayVoidBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playVoidBtn;
}

- (UISlider *)slider{
    if (!_slider) {
        _slider = [[UISlider alloc] initWithFrame:CGRectMake(30, 600, 300, 30)];
        _slider.maximumValue = 1;
        _slider.minimumValue = 0;
        _slider.thumbTintColor = [UIColor blueColor];
        _slider.tintColor = [UIColor redColor];
        _slider.continuous = YES;
        [_slider addTarget:self action:@selector(playerProcess:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

-(AVPlayer *)player{
    if (!_player) {
        AVPlayerItem *playerItem=[self getPlayItem:0];
        _player=[AVPlayer playerWithPlayerItem:playerItem];
    }
    return _player;
}

-(AVPlayerItem *)getPlayItem:(int)videoIndex{
    NSString * urlStr = [[NSBundle mainBundle]pathForResource:@"movie.MP4" ofType:nil];
    
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    
    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:url];
    return playerItem;
}

- (SCNNode *)showNode {
    if (_showNode == nil) {
        _showNode = [SCNNode new];
        SCNBox * box = [SCNBox boxWithWidth:0.3 height:0.3 length:0.3 chamferRadius:0];
        _showNode.geometry = box;
        _showNode.position = SCNVector3Make(0, 0.5, -1);
    }
    return _showNode;
}

@end
