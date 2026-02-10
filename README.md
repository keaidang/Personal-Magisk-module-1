# magisk模块 Auto MV Magisk 模块说明

## 此仓库只作为个人备份用
## ！！root,su为安卓系统的最高权限 请谨慎挂载任何magisk模块

## 功能行为

- 在后台扫描安卓设备任意目录下的文件将其在后台转移到任意目录 并进行重命名操作。
- 后台每 10 秒扫描一次 'auto_mv_worker.sh'中第五行的写的目录。
- 文件名以 `VID` 开头的文件会被移动到 'auto_mv_worker.sh'第六行写的目录。
- 用户可修改'auto_mv_worker.sh'设置好源目录,目标目录,重命名规则后直接打包刷入。
- 如果文件名以 `.mp4` 或 `.MP4` 结尾，移动时会去掉该后缀。
- 如果文件名以 `VID_` 开头，重命名时会去掉这个前缀。
- 为避免搬运未写完文件，会先等待 2 秒并确认文件大小稳定后再移动。
## 目录结构

- module.prop
- customize.sh
- post-fs-data.sh
- service.sh
- uninstall.sh
- action.sh
- system.prop
- sepolicy.rule
- common/
- system/
- META-INF/com/google/android/

## 快速测试

- 在 Magisk 中安装模块 zip。
- 重启设备。
- 往 `DCIM/Camera` 放入一个新文件，例如 `VID_20260210_123456.mp4`。
- 检查 `/storage/emulated/0/Music/20260210_123456` 是否生成。

## 打包方式

将当前目录下模块文件压缩为 zip 后，在 Magisk App 中安装。
