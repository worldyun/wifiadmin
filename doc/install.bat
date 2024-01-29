@echo off
CHCP 65001
CLS

REM 获取后台地址
ECHO 欢迎使用一键安装脚本, 在开始之前请认真阅读以下内容 
ECHO 1. 请确保你的设备已开机, 并通过USB成功连接至电脑, 且后台登录密码为admin 
ECHO 2. 请确保刷入期间没有其他ADB设备接入电脑 
ECHO 3. 刷入期间, 确保设备与电脑不断开连接, 如拔出设备、关闭电脑等 
ECHO 请输入设备后台地址: 
SET /p _device_ip= 

REM  登录后台并获取相关数据
SET _http_res=NULL
FOR /f "tokens=*" %%A IN ('curl -m 2 -s -X POST -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" -d "goformId=LOGIN&password=YWRtaW4=" "http://%_device_ip%/goform/goform_set_cmd_process"') DO SET _http_res=%%A
ECHO %_http_res%
IF NOT "%_http_res%" == "{"result":"0"}" (
    ECHO 登录失败,请检查设备是否连接或后台地址是否正确 
    GOTO END
)

@REM 获取数据,校验硬件版本是否支持
ECHO 登录成功, 正在获取后台数据 
@REM 延迟一秒
TIMEOUT /t 1 > nul
SET _http_res=NULL
FOR /f "tokens=*" %%A IN ('curl -m 2 -s -H "Accept: application/json, text/javascript, */*; q=0.01" -H "Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6" -H "'Content-Type: application/x-www-form-urlencoded; charset=UTF-8" "http://%_device_ip%/goform/goform_get_cmd_process?cmd=hw_version"') DO SET _http_res=%%A
ECHO %_http_res%
IF NOT %_http_res% == {"hw_version":"F231ZC_V1.0_OM_OM"} (
    ECHO 暂不支持此设备,如果你想测试是否支持,可使用随身Wifi助手刷入,记得备份原版后台 
    GOTO END
)


ECHO 硬件版本校验成功, 正在开启ADB, 在设备重启之前请勿关闭或拔出设备, 否则将可能导致设备损坏 
@REM 延迟一秒
TIMEOUT /t 1 > nul
curl -m 10 -s -H "Accept: application/json, text/javascript, */*; q=0.01" -H "Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6" -H "'Content-Type: application/x-www-form-urlencoded; charset=UTF-8" "http://%_device_ip%/goform/goform_set_cmd_process?goformId=SET_DEVICE_MODE&debug_enable=2"
@REM 危险操作, 即时检测 
IF %errorlevel% NEQ 0 GOTO enable_adb_error
TIMEOUT /t 2 > nul
SET _http_res=NULL
FOR /f "tokens=*" %%A IN ('curl -m 10 -s -H "Accept: application/json, text/javascript, */*; q=0.01" -H "Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6" -H "'Content-Type: application/x-www-form-urlencoded; charset=UTF-8" "http://%_device_ip%/goform/goform_set_cmd_process?goformId=SET_DEVICE_MODE&debug_enable=1"') DO SET _http_res=%%A
IF %errorlevel% NEQ 0 GOTO enable_adb_error
ECHO %_http_res%
IF NOT %_http_res% == {"result":"set_devicemode successfully!"} (
    ECHO 开启ADB失败 
    GOTO enable_adb_error
)

ECHO 开启ADB成功, 正在重启设备 
@REM 延迟一秒
TIMEOUT /t 1 > nul
curl -m 2 -s -H "Accept: application/json, text/javascript, */*; q=0.01" -H "Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6" -H "'Content-Type: application/x-www-form-urlencoded; charset=UTF-8" "http://%_device_ip%/goform/goform_set_cmd_process?goformId=REBOOT_DEVICE"
ECHO OK

ECHO 设备已重启 
ECHO 正在等待设备开机... 
@REM 延迟5秒
TIMEOUT /t 5 > nul
:ping_loop
PING -n 1 -w 1000 %_device_ip% > nul
IF %errorlevel% EQU 0 GOTO online
TIMEOUT /t 5 > nul
ECHO 正在等待设备开机... 
GOTO ping_loop

:online
ECHO 设备已上线, 正在连接ADB 
@REM 计算ADB设备数量
SET _device_count=0
REM 获取当前连接的Android设备列表
adb devices > nul
adb devices > nul
adb devices > nul
FOR /f "tokens=1 delims= " %%a IN ('adb devices') DO (
    REM 判断设备状态是否为"device"
    IF NOT "%%a" == "List" (
      SET /a _device_count+=1
    )
)
IF NOT %_device_count% == 1 (
    ECHO ADB设备数量为%_device_count%, 请检查设备ADB是否成功开启, 或拔出其他ADB设备  
    GOTO END
)

@REM 测试连接ADB
TIMEOUT /t 1 > nul
SET _adb_output=NULL
FOR /f "tokens=*" %%A IN ('adb shell echo connected') DO SET "_adb_output=%%A"
IF NOT "%_adb_output%" == "connected" (
    ECHO ADB连接失败 
    GOTO END
)

@REM 检测设备WEB目录是否正确
ECHO ADB连接成功, 正在检测设备WEB目录 
TIMEOUT /t 1 > nul
SET _adb_output=NULL
FOR /f "tokens=*" %%A IN ('adb shell ls /etc_ro/web/index.html') DO SET "_adb_output=%%A"
ECHO %_adb_output%|findstr "^No such file or directory" >nul
IF %errorlevel% EQU 0 (
    ECHO 设备WEB目录检测失败 
    GOTO END
)
@REM IF NOT "%_adb_output%" == "/etc_ro/web/index.html" (
@REM     ECHO 设备WEB目录检测失败 
@REM     GOTO END
@REM )

@REM 备份原WEB后台
ECHO 设备WEB目录检测成功, 正在备份原WEB后台 
TIMEOUT /t 1 > nul
adb pull /etc_ro/web ./web_backup
IF NOT %errorlevel% EQU 0 (
    ECHO 设备WEB目录检测失败 
    GOTO END
)
@REM SET _adb_output=NULL
@REM FOR /f "tokens=1 delims=:" %%A IN ('adb pull /etc_ro/web ./web_backup') DO SET "_adb_output=%%A"
@REM IF NOT "%_adb_output%" == "/etc_ro/web/" (
@REM     ECHO 备份原WEB后台失败 
@REM     GOTO END
@REM )
ECHO 备份原WEB后台成功, 备份文件在web_backup目录, 请妥善保存 

@REM 计算剩余空间大小 
ECHO 正在计算设备剩余空间, 以供参考 
TIMEOUT /t 1 > nul
SET _available=NULL
FOR /f "tokens=1,4 delims= " %%A IN ('adb shell df -h') DO (
  IF "%%A" == "/dev/mtdblock4" (
    SET _available=%%B
  )
)
ECHO 当前设备剩余空间为: %_available% 

SET _web_backup_size=NULL
FOR /f "tokens=3,5 delims= " %%A IN ('dir web_backup /s') DO (
  IF "%%B" == "free" (
    GOTO get_web_backup_size
  )
  SET _web_backup_size=%%A
)
:get_web_backup_size
ECHO 原WEB大小为: %_web_backup_size%B

SET _web_size=NULL
FOR /f "tokens=3,5 delims= " %%A IN ('dir web /s') DO (
  IF "%%B" == "free" (
    GOTO get_web_size
  )
  SET _web_size=%%A
)
:get_web_size
ECHO 新WEB大小为: %_web_size%B 

ECHO 请自行计算空间是否能够刷入, 如果空间不足, 刷入后会丢失后台 
ECHO 计算规则为: 设备剩余空间 + 原WEB大小 大于 新WEB大小 
ECHO 确认关闭请输入 Y 并回车, 否则请输入 N 并回车  
SET /p _confirm= 
IF NOT "%_confirm%" == "Y" (
    ECHO 已取消刷入 
    GOTO END
)

ECHO 确认刷入, 正在检测设备WEB目录是否可写 
TIMEOUT /t 1 > nul
@REM 重新挂载根目录为可读写
adb shell mount -o rw,remount /
TIMEOUT /t 1 > nul
@REM 测试读写
adb shell touch /etc_ro/web/test.txt
TIMEOUT /t 1 > nul
SET _adb_output=NULL
FOR /f "tokens=*" %%A IN ('adb shell ls /etc_ro/web/test.txt') DO SET "_adb_output=%%A"
ECHO %_adb_output%|findstr "^No such file or directory" >nul
IF %errorlevel% EQU 0 (
    ECHO WEB目录不可写 
    GOTO END
)
@REM IF NOT "%_adb_output%" == "/etc_ro/web/test.txt" (
@REM     ECHO WEB目录不可写 
@REM     GOTO END
@REM )

ECHO 读写测试通过, 正在删除原WEB后台 
TIMEOUT /t 1 > nul
adb shell rm -rf /etc_ro/web
TIMEOUT /t 1 > nul
ECHO 正在刷入新后台, 将耗时约30S, 请耐心等待 
adb push web /etc_ro/

@REM 验证刷入是否成功
ECHO 刷入完成, 正在验证是否刷入成功 
TIMEOUT /t 1 > nul
SET _adb_output=NULL
FOR /f "tokens=*" %%A IN ('adb shell ls /etc_ro/web/index.html') DO SET "_adb_output=%%A"
ECHO %_adb_output%|findstr "^No such file or directory" >nul
IF %errorlevel% EQU 0 (
    ECHO 刷入失败 
    GOTO END
)
@REM IF NOT "%_adb_output%" == "/etc_ro/web/index.html" (
@REM     ECHO 刷入失败 
@REM     GOTO END
@REM )

ECHO 刷入成功, 请打开%_device_ip%查看新后台 

ECHO 是否关闭设备ADB?  
ECHO 确认关闭请输入 Y 并回车, 否则请输入 N 并回车  
SET /p _confirm= 
IF NOT "%_confirm%" == "Y" (
    ECHO 设备ADB将不会被关闭, 您可在后台 高级设置 > 其他设置 > 中兴微ADB 自行关闭 
    GOTO END
)

ECHO 正在关闭ADB 
curl -m 10 -s -H "Accept: application/json, text/javascript, */*; q=0.01" -H "Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6" -H "'Content-Type: application/x-www-form-urlencoded; charset=UTF-8" "http://%_device_ip%/goform/goform_set_cmd_process?goformId=SET_DEVICE_MODE&debug_enable=0"
curl -s -H "Accept: application/json, text/javascript, */*; q=0.01" -H "Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6" -H "'Content-Type: application/x-www-form-urlencoded; charset=UTF-8" "http://%_device_ip%/goform/goform_set_cmd_process?goformId=SET_DEVICE_MODE&debug_enable=0"
TIMEOUT /t 2 > nul
ECHO 正在重启设备 
curl -s -H "Accept: application/json, text/javascript, */*; q=0.01" -H "Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6" -H "'Content-Type: application/x-www-form-urlencoded; charset=UTF-8" "http://%_device_ip%/goform/goform_set_cmd_process?goformId=REBOOT_DEVICE"
GOTO END







:enable_adb_error
ECHO 开启ADB命令执行失败, 正在尝试恢复, 请等待脚本自行完毕, 以避免设备变砖 
curl -m 10 -s -H "Accept: application/json, text/javascript, */*; q=0.01" -H "Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6" -H "'Content-Type: application/x-www-form-urlencoded; charset=UTF-8" "http://%_device_ip%/goform/goform_set_cmd_process?goformId=SET_DEVICE_MODE&debug_enable=0"
curl -m 10 -s -H "Accept: application/json, text/javascript, */*; q=0.01" -H "Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6" -H "'Content-Type: application/x-www-form-urlencoded; charset=UTF-8" "http://%_device_ip%/goform/goform_set_cmd_process?goformId=SET_DEVICE_MODE&debug_enable=0"
curl -s -H "Accept: application/json, text/javascript, */*; q=0.01" -H "Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6" -H "'Content-Type: application/x-www-form-urlencoded; charset=UTF-8" "http://%_device_ip%/goform/goform_set_cmd_process?goformId=SET_DEVICE_MODE&debug_enable=0"
TIMEOUT /t 5 > nul
curl -s -H "Accept: application/json, text/javascript, */*; q=0.01" -H "Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6" -H "'Content-Type: application/x-www-form-urlencoded; charset=UTF-8" "http://%_device_ip%/goform/goform_set_cmd_process?goformId=REBOOT_DEVICE"

:END
ECHO 按任意键退出 
PAUSE