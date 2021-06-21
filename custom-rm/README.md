## 自定义 RM

该脚本用于替代系统自带 `rm` 命令，执行删除时不会真正删除文件，将文件移动入备份目录。

### 初始化

`custom-rm` 需要简单的几步初始化操作。

1. 创建备份目录 `/backup`，并设置目录权限为所有用户允许访问与修改。

```shell
mkdir /backup
chmod 777 /backup
```

2. 修改系统自带 `rm` 命令，并将当前脚本文件拷贝进入替换。

```shell
# 重命名系统自带rm文件
mv /usr/bin/rm /usr/bin/zrm

# 将 rm.sh 文件拷贝到 /usr/bin 目录
cp ~/rm.sh /usr/bin/rm
```

3. 完成，接下来就可以正常使用 `rm` 文件进行删除，删除的文件都将存储在备份目录
```shell
/backup/$USER/$DELETE_DATE/$DELETE_TIME/删除目录
```
删除完成后系统并不会自动删除备份文件，需要手动对备份文件进行删除。