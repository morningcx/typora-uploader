# typora-uploader

本人在使用Typora上传图片时是使用GitHub作为图床的，Typora常用的图片上传工具有iPic、uPic、PicGo等，但在使用PicGo等工具上传Github图片时经常遇到上传失败的现象，原因PicGo的作者在[这里](https://github.com/Molunerfinn/PicGo/blob/dev/FAQ.md#7-github-%E5%9B%BE%E5%BA%8A%E6%9C%89%E6%97%B6%E8%83%BD%E4%B8%8A%E4%BC%A0%E6%9C%89%E6%97%B6%E4%B8%8A%E4%BC%A0%E5%A4%B1%E8%B4%A5)也写得很明白了，另一方面仅针对Typora使用图片上传工具过于笨重，并且需要开启常驻后台，如果对性能要求比较高的用户可能不太能接受。

Typora中的上传服务还支持自定义命令，用户可以编写自己的脚本命令来实现图片的上传，具体开发文档详见[Typora官方文档](http://support.typora.io/Upload-Image/#custom)。本人也针对Typora的自定义命令文档以及Git上传相关操作简单整合成了typora-uploader.bat脚本用于支持Typora最基本的本地图片上传功能。

## 脚本

```bat
@echo off

::git目录
set gitDir=E:\Program\Project\typora-uploader\img\
::域名
set domain=https://cdn.jsdelivr.net/gh/morningcx/typora-uploader/img/

::基本变量
set logDir=%~dp0
set currDate=%date%
set currTime=%time%
echo ==========%currDate%%currTime%========== >>%logDir%uploader.log 2>&1


::获取上传图片的本地路径
set sourceFile=%1
echo sourceFile %sourceFile% >>%logDir%uploader.log 2>&1

::输入文件参数为空或文件不存在则退出
if "%sourceFile%"=="" (
    echo empty sourceFile >>%logDir%uploader.log 2>&1
    goto end
)
if not exist %sourceFile% (
    echo file not exist >>%logDir%uploader.log 2>&1
    goto end
)

::获取图片后缀名(带.)
set sourceSuffix=%~x1

::获取时间戳
set timestamp=%currDate:~0,4%%currDate:~5,2%%currDate:~8,2%%currTime:~0,2%%currTime:~3,2%%currTime:~6,2%%currTime:~9,2%

::重命名图片文件
set filename=%timestamp: =0%%sourceSuffix%
echo filename %filename% >>%logDir%uploader.log 2>&1


::如果是截图，则图片文件存储在typora-user-images文件夹下，需要剪切到git目录下，如果是本地图片，则需要将图片拷贝到git目录下
echo %sourceFile% | find /i "typora-user-images">nul && (
    echo move file >>%logDir%uploader.log 2>&1
    move %sourceFile% %gitDir%%fileName% >>%logDir%uploader.log 2>&1
) || (
    echo copy file >>%logDir%uploader.log 2>&1
    copy %sourceFile% %gitDir%%fileName% >>%logDir%uploader.log 2>&1
)

::git处理，需要缓存git凭证，否则运行git脚本将无法结束
echo git process >>%logDir%uploader.log 2>&1

cd /d %gitDir%

git pull >>%logDir%uploader.log 2>&1

git add . >>%logDir%uploader.log 2>&1

git commit -m "Upload by Typora" >>%logDir%uploader.log 2>&1

git push >>%logDir%uploader.log 2>&1

set url=%domain%%fileName%

echo Upload Success:
echo %url%

::复制markdown到剪贴板
echo ![](%url%) | clip

:end
```


## 配置

![image-20200809130202044](https://cdn.jsdelivr.net/gh/morningcx/typora-uploader/img/2020080913020211.png)

## 使用

使用方法很简单

1. typora-uploader.bat脚本clone到本地、git图床clone到本地，在脚本中将本地git目录以及远程域名（[jsDelivr](https://github.com/jsdelivr/jsdelivr)）配置完成
2. Typora偏好设置中上传服务选定为Custom Command，自定义命令路径指向typora-uploader.bat
3. 复制本地图片或截图至Typora时将自动上传至GitHub图床

## 注意事项

typora-uploader.bat脚本仅支持Windows上Typora本地图片的单个上传操作，对于一些批量上传、网络图片上传都没有很好的支持，并且上传原理是基于git命令行的，故对比上传工具而言效率较低，但使用typora-uploader.bat上传只有运行时的消耗，上传结束后会自动销毁，开销方面会更低，并且使用git命令提交的方式下，上传失败的概率较低。

Typora中使用typora-uploader.bat或工具上传图片时都存在各自的优缺点，还是根据个人喜好进行选择吧O(∩_∩)O

