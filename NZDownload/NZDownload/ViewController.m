//
//  ViewController.m
//  NZDownload
//
//  Created by 诸超杰 on 16/3/22.
//  Copyright © 2016年 诸超杰. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSURLSessionDownloadDelegate>
@property (weak, nonatomic) IBOutlet UISlider *downloadSlider;
@property (nonatomic, assign) double value;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *task;

@end

@implementation ViewController


- (IBAction)activityButton:(id)sender {
    [self createTaskByURLString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
    [self.task resume];
}
- (IBAction)endButton:(id)sender {
//    [self.task cancel];
//断点续载时，不要执行cancellfan方法
//而且断点续载时，一个代理方法将被执行
    if (self.task) {
        [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            self.data = resumeData;
            self.task = nil;//置空任务
        }];
     }
}

- (NSURLSession *)session {
    if (_session == nil) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
#warning 这里设置一个主线程.完成后测试改动 这里设置的工作模式，完成够测试改动
    }
    return _session;
}


- (void)createTaskByURLString:(NSString *)URLString {
    if (self.data != nil) {
        self.task = [self.session downloadTaskWithResumeData:self.data];
    
        self.downloadSlider.value = self.value;
        NSLog(@"self.data:%@,self.value:%f",self.data,self.value);
    } else {
    self.task = [self.session downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URLString]]];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.downloadSlider.value = 0;
    
    
}


//断点续载时，一个任务将会被执行
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
//    fileOffset处开始下载
//    expectedTotalBytes期望收到的所有的信息
    self.downloadSlider.value = fileOffset;
    NSLog(@"任务断续：fileOffset：%lld",fileOffset);
}

//下载完成后执行的返回错误信息的任务
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    //这个方无论成功与否都会执行！
    NSLog(@"如果下载失败，那么的原因：%@",error);
}
//下载成功执行的任务
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {

    //下载成功调用此方法,
    NSFileManager *fileManager = [NSFileManager defaultManager];//文件管理
    NSURL *documentsDirectory=[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingString:@"/Documents/"]];
    NSURL *destinationPath = [documentsDirectory URLByAppendingPathComponent:@"Backkom.mp4"];
    NSError *error;
    [fileManager removeItemAtURL:destinationPath error:NULL];//确保文件不在
    BOOL success = [fileManager copyItemAtURL:location toURL:destinationPath error:&error];
    if(success){
        NSLog(@"success path:%@",destinationPath);
    }else{
        NSLog(@"error:%@",error);
    }
}
//下载进度的任务
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"%@",[NSThread currentThread]);
//    bytesWritten--每次写入的data字节数;
//    totalBytesWritten--当前一共写入的data字节数;
//    totalBytesExpectedToWrite--期望收到的所有data字节数;
#warning 在第二次下载的时候，这个最大值怎么设置什么的  还是有些不知道
    self.downloadSlider.maximumValue = totalBytesExpectedToWrite;
    self.downloadSlider.value = totalBytesWritten  ;    NSLog(@" %lld  %lld",totalBytesWritten, totalBytesExpectedToWrite);
    self.value = totalBytesWritten ;
}

















- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
