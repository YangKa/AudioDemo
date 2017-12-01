## 音频播放和录制

准备研究下音频方面的播放和录制方式有哪些

### 音频播放方式

##### 1.采用MediaPlayer库，只能播放手机音乐库中的音乐

- 通过MPMediaPickerController展示音乐列表
- 选择MPMediaItem
- 通过MPMusicPlayerController播放，会自动在锁屏下展示音频播放界面

##### 2.采用AVFoundation库

- 通过AVAudioPlayer播放
- 需要自己监听处理各种音频干扰情况

##### 3.采用AVFoundation库

- 通过AVPlayer播放
- 可以实时监听播放状态

##### 4.采用AVFoundation库

- 通过AVPlayer播放
- 可以实时监听播放状态

##### 5.采用AVFoundation库

- 采用AVAudioEngine音频引擎播放音频节点AVAudioPlayerNode
- 给引擎配置unitTimePitch、unitDistortion、unitReverb
- 给音频节点添加不同时间点播放的音频文件AVAudioFile

##### 6.采用AVFoundation库

通过音频队列AudioQueueRef

-   1.自定义一个管理文件格式、路径等信息的结构体
-   2.定义一个音频队列函数去执行播放功能
-   3.定义音频队列缓存区的大小
-   4.open一个需要播放的音频文件，并且定义它的数据编码格式
-   5.创建一个音频队列并且配置它
-   6.为缓存区分配内存和入队列。启动音频队列播放，并在callback函数中适当时候结束它。
-   7.销毁音频队列

##### 7.采用AudioToolbox库

采用系统播放铃声的API，但有30s的时间限制

- 通过AudioServicesCreateSystemSoundID创建SystemSoundID
- 播放音频AudioServicesPlayAlertSoundWithCompletion

### 音频录制方式

采用AVFoundation库

##### 1.采用AVAudioEngine录制


##### 2.采用AVAudioRecorder录制


##### 3.采用音频队列录制

- 1.自定义一个结构体，包含音频格式、保存路径等信息
- 2.实现一个录音回调函数处理录音
- 3.给音频队列缓存设置一个合适的大小。如果用刀use cookies，设置一下magic cookies。
- 4.设置结构体其它信息，包括数据流格式、保存路径等
- 5.创建一个音频队列，一个音频缓存队列，一个存放音频数据的文件。
- 6.启动录音
- 7.停止录音并销毁它。音频队列需要销毁缓存。