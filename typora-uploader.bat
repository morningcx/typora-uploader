@echo off

::curl -sIL -w "%%{content_type}" -o null https://iknow-pic.cdn.bcebos.com/8b13632762d0f7038dd4a4aa05fa513d2697c565

::git目录
set gitDir=E:\Program\Project\assets\img\
::域名
set domain=https://cdn.jsdelivr.net/gh/morningcx/assets/img/

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