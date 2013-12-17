非ARC，支持文件、内存缓存

###使用方法
```
TZAsynchImageView *imageView = [[[TZAsynchImageView alloc] initWithUrlString:@"url" frame:self.view.bounds placeholder:[UIImage imageNamed:@"p.jpg"] autorelease];
```
or
```
[imageView setUrlString:@"url"];
[imageView setUrlString:@"url" placeholder:[UIImage imageNamed:@"p.jpg"]];
```
清除文件缓存
```
[TZAsynchDownloader clearCacheFilesBefore:[NSDate date]];
[TZAsynchDownloaderclearAllCacheFiles];
```
清除内存缓存,每次退出一个界面的时候，可以清理一次
```
[[TZAsynchDownloader getInstance] clearMemoryFiles];
```
###原理
>1. 查找urlString是否在cache，如果不在到2，否则执行6
2. 查找urlString是否在文件中，如果不在到3，否则把图片加入cache，执行6
3. 注册kDownloadedImage的消息，下载单例开始下载
4. 下载完成，存入cache，存入文件，发出kDownloadedImage消息
5. 所有注册kDownloadedImage的imageview执行1
6. 返回图片