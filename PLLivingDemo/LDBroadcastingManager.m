//
//  LDBroadcastingManager.m
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import "LDBroadcastingManager.h"

@implementation LDBroadcastingManager

- (PLCameraStreamingSession *)generateCameraStreamingSession
{
    // 视频采集配置，对应的是摄像头。
    PLVideoCaptureConfiguration *videoCaptureConfiguration;
    // 视频推流配置，对应的是推流出去的画面。
    PLVideoStreamingConfiguration *videoStreamingConfiguration;
    // 音频采集配置，对应的是麦克风。
    PLAudioCaptureConfiguration *audioCaptureConfiguration;
    // 音频推流配置，对应的是推流出去的声音。
    PLAudioStreamingConfiguration *audioSreamingConfiguration;
    // 摄像头采集方向
    AVCaptureVideoOrientation captureOrientation;
    
    videoCaptureConfiguration =
        [[PLVideoCaptureConfiguration alloc] initWithVideoFrameRate:30
                                                      sessionPreset:AVCaptureSessionPresetMedium
                                           previewMirrorFrontFacing:YES
                                            previewMirrorRearFacing:NO
                                            streamMirrorFrontFacing:NO
                                             streamMirrorRearFacing:NO
                                                     cameraPosition:AVCaptureDevicePositionBack//后置摄像头
                                                   videoOrientation:AVCaptureVideoOrientationPortrait];
    
    audioCaptureConfiguration = [PLAudioCaptureConfiguration defaultConfiguration];
    
    // videoSize 指推流出去后的视频分辨率，建议与摄像头的采集分辨率设置得一样。
    CGSize videoSize = CGSizeMake(480 , 640);
    
    videoStreamingConfiguration =
        [[PLVideoStreamingConfiguration alloc] initWithVideoSize:videoSize
                                    expectedSourceVideoFrameRate:30
                                        videoMaxKeyframeInterval:90
                                             averageVideoBitRate:512 * 1024
                                               videoProfileLevel:AVVideoProfileLevelH264Baseline31];
    
    // 让摄像头的采集方向与设备的实际方向一致。
    // 这样才能保证，主播把手机横放时，播出去的画面方向依然是“正”的。
    audioSreamingConfiguration = [PLAudioStreamingConfiguration defaultConfiguration];
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if (deviceOrientation == UIDeviceOrientationPortrait ||
        deviceOrientation == UIDeviceOrientationPortraitUpsideDown ||
        deviceOrientation == UIDeviceOrientationLandscapeLeft ||
        deviceOrientation == UIDeviceOrientationLandscapeRight) {
        captureOrientation = (AVCaptureVideoOrientation) deviceOrientation;
    } else {
        captureOrientation = AVCaptureVideoOrientationPortrait;
    }
    
    // PLStream 标示一个流对象，对于 PLCameraStreamingSession 而言，如果为 nil，它将不能推流。
    // 此时，它仅仅具备把摄像头采集到的画面展现在 preview 上的能力。
    // 如果你希望 PLCameraStreamingSession 一构造好就立即能推流，请事先获取 PLStream 并作为参数传进去。
    //
    // 从网络获取 PLStream 需要耗费一些时间。因此我在构造 PLCameraStreamingSession 时故意留下一个 nil。
    // 然后通过异步获取 PLStream 再 set 进去。
    //
    // 如此一来，主播一打开界面就能立即看到 preview 画面，即便此刻她还不能开始推流（因为 PLStream 还没有拿到）。
    // 这样处理，虽然代码量要稍稍增加一点点，但主播的体验会好很多。
    PLStream *stream = nil;
    
    return [[PLCameraStreamingSession alloc] initWithVideoCaptureConfiguration:videoCaptureConfiguration
                                                     audioCaptureConfiguration:audioCaptureConfiguration
                                                   videoStreamingConfiguration:videoStreamingConfiguration
                                                   audioStreamingConfiguration:audioSreamingConfiguration
                                                                        stream:stream
                                                              videoOrientation:captureOrientation];
}

- (void)generateStreamObject:(NSURL *)streamCloudURL withComplete:(LDBroadcastingComplete)completeBlock
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:streamCloudURL];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 10;
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable responseError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = responseError;
            if (error != nil || response == nil || data == nil) {
                // 获取 stream JSON 失败
                completeBlock(nil, LDBroadcastingStreamObjectError_CanNotGetJSON);
                return;
            }
            NSDictionary *streamJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error != nil || streamJSON == nil) {
                // 解析 JSON 失败
                completeBlock(nil, LDBroadcastingStreamObjectError_ParseJSONFail);
                return;
            }
            completeBlock([PLStream streamWithJSON:streamJSON], LDBroadcastingStreamObjectError_NoError);
        });
    }];
    [task resume];
}

@end
