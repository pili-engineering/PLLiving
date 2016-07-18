//
//  LDBroadcastingManager.h
//  PLLivingDemo
//
//  Created by TaoZeyu on 16/7/18.
//  Copyright © 2016年 com.pili-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    LDBroadcastingStreamObjectError_NoError,
    LDBroadcastingStreamObjectError_CanNotGetJSON,
    LDBroadcastingStreamObjectError_ParseJSONFail
} LDBroadcastingStreamObjectError;

typedef void (^LDBroadcastingComplete)(PLStream *streamObject, LDBroadcastingStreamObjectError error);

@interface LDBroadcastingManager : NSObject

@property (nonatomic, strong) PLCameraStreamingSession *cameraStreamingSession;

- (PLCameraStreamingSession *)generateCameraStreamingSession;
- (void)generateStreamObject:(NSURL *)streamCloudURL withComplete:(LDBroadcastingComplete)completeBlock;

@end
