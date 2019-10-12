//
//  ViewController.m
//  语音录制
//
//  Created by 张冲 on 2018/4/26.
//  Copyright © 2018年 张冲. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController (){
    NSString *filePath;

}
@property (nonatomic,strong)AVAudioPlayer *player;
@property (nonatomic,strong)AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioSession *session;
@property (nonatomic, strong) NSURL *recordFileUrl; //文件地址


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(100, 100,100, 50)];
    [button setTitle:@"录音" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor redColor]];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

    UIButton *stopbutton = [[UIButton alloc]initWithFrame:CGRectMake(100, 200,100, 50)];
    [stopbutton setTitle:@"停止" forState:UIControlStateNormal];
    [stopbutton setBackgroundColor:[UIColor greenColor]];
    [stopbutton addTarget:self action:@selector(stopbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopbutton];

    UIButton *playbutton = [[UIButton alloc]initWithFrame:CGRectMake(100, 300,100, 50)];
    [playbutton setTitle:@"播放" forState:UIControlStateNormal];
    [playbutton setBackgroundColor:[UIColor greenColor]];
    [playbutton addTarget:self action:@selector(playbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playbutton];

    // Do any additional setup after loading the view, typically from a nib.
}
- (void)buttonClick:(UIButton *)button{
    AVAudioSession *session =[AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];

    if (session == nil) {

        NSLog(@"Error creating session: %@",[sessionError description]);

    }else{
        [session setActive:YES error:nil];

    }

    self.session = session;


    //1.获取沙盒地址
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    filePath = [path stringByAppendingString:@"/RRecord.aac"];
    NSLog(@"filrPath = %@",filePath);

    //2.获取文件路径
    self.recordFileUrl = [NSURL fileURLWithPath:filePath];

    //设置参数
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   //采样率  8000/11025/22050/44100/96000（影响音频的质量）
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey,
                                   // 音频格式
                                   [NSNumber numberWithInt: kAudioFormatMPEG4AAC],AVFormatIDKey,
                                   //采样位数  8、16、24、32 默认为16
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                   // 音频通道数 1 或 2
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                   //录音质量
                                   [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                   nil];


    _recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFileUrl settings:recordSetting error:nil];

    if (_recorder) {

        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
        [_recorder record];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            [self stopbuttonClick:nil];
         });



    }else{
        NSLog(@"音频格式和文件存储格式不匹配,无法初始化Recorder");

    }


}
- (void)playbuttonClick:(UIButton *)button{
    NSLog(@"播放录音");
    [self.recorder stop];

    if ([self.player isPlaying])return;

    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordFileUrl error:nil];



    NSLog(@"%li",self.player.data.length/1024);



    [self.session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self.player play];


}
- (void)stopbuttonClick:(UIButton *)button{
    [_recorder stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
