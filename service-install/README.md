## Java 程序安装服务

​	`service-install` 能够一键将 `JAVA` 程序安装为服务，提供一键安装、卸载功能，并提供服务管理命令。



### 一、开始使用

安装程序使用步骤：

1. 将程序执行文件、配置文件等拷贝到安装程序 `install` 脚本同级目录下；
2. 编辑 `app.config` 配置文件，填写安装程序信息和安装路径；
3. 执行 `./install` 脚本进行安装（需要 `root` 权限）。



执行 `./install help` 可查看脚本帮助，安装程序目前具有如下功能。

#### 1.1 环境校验

环境校验分安装校验和更新校验。

**1. 安装校验** 

​		执行 `install -c` 进行安装校验。

​		首先判断安装环境是否可用，包括检验安装包完整性、系统环境是否可用（如 `service` 、命令是否已存在等）、安装路径是否可用。



**2. 更新校验** 

​		执行 `install -c update` 进行更新校验。

​		首先判断更新环境是否可用，包括检验安装包完整性、系统环境是否可用（如 `service` 、命令是否不存在等）、`version` 版本是否是当前版本，`service` 是否已经启动。



#### 1.2 安装流程

执行 `./install` 进行更新校验，安装时需要 `root` 权限。

1. 执行安装校验；
2. 安装时将可执行程序文件、依赖的 `LIB_PATH` 中的路径拷贝到安装路径；
3. 创建 `service` 文件，拷贝到系统 `service` 路径，并刷新 `service` 配置；
4. 根据安装信息创建服务管理命令。



#### 1.3 更新流程

执行 `./install -u` 进行更新校验，更新时需要 `root` 权限。

1. 执行更新校验；
2. 更新时将先整理出更新可能会覆盖的程序，如果会覆盖文件将会提醒用户，之后将可执行程序文件、依赖的 `LIB_PATH` 中的路径拷贝到安装路径；
3. 创建 `service` 文件，拷贝到系统 `service` 路径覆盖原文件，并刷新 `service` 配置；
4. 根据安装信息创建服务管理命令覆盖原命令文件。

#### 1.4 环境清理 

执行 `./install --clear-all` 进行环境清理，环境清理时需要 `root` 权限。

​		如果在安装时，提示安装环境存在残留数据等问题无法通过校验，或者想要清除已安装的信息。可使用环境清理。环境清理时将环境清理的文件移到备份目录 `install_tool/back/$TIME` 目录下。



### 二、 app.config 配置介绍

完整的 `app.config` 配置内容如下：

```properties
# （必须）应用服务名称，需要确保当前系统没有该同名服务
SERVICE_NAME=nineya-blog
# （必须）服务对应的安装程序文件名
SERVICE_FILE=blog-1.2.0.jar
# （必须）服务程序的main方法类
MAIN_FUNCTION=com.nineya.blog.AuthMain
# 服务描述
SERVICE_DESC=
# 服务版本，默认为1.0.0
VERSION=1.2.0
# 服务安装位置，默认为/opt/$SERVICE_NAME
INSTALL_PATH=/www/wwwroot/blog
# JAVA环境变量
JAVA_HOME=/usr/lib/jvm/jre-11-openjdk-11.0.11.0.9-1.el7_9.x86_64
# JVM选项（多个参数用空格隔开，需要用“"”号包裹）
JVM_OPTIONS=-Xmx240m
# 程序需要的参数（多个参数用空格隔开，需要用“"”号包裹）
PROGRAM_ARGUMENTS=
# 服务依赖的某些程序的路径，安装时需要一同安装，多个路径用“,”分隔
LIB_PATH=lib/*
# 服务更新时需要更新的依赖包，多个路径用“,”分隔
UPDATE_PATH=
# 服务安装后的管理命令，默认为$SERVICE_NAME
COMMEND_NAME=blog
```

​		在配置文件中所有配置，如果存在空格等特殊符号，需要用 `"` 包裹，否则程序无法正常运行。

详细说明：

- `SERVICE_NAME`：（必须）服务名称，表示将要添加到服务器 `service` 中的服务名称，不能和已有的 `service` 重名。
- `SERVICE_FILE`：（必须）执行程序名称，将要安装为服务的可执行 `jar` 文件。如果你的 `jar` 程序依赖了其他的 `jar` 包，可以新建 `lib` 目录，将这些工具包添加到 `lib` 目录下，并将 `lib` 目录添加到 `LIB_PATH` 中。
- `MAIN_FUNCTION`：（必须）`main` 方法类，需要指定 `jar` 文件的 `main` 方法所在的类，需要注意的是在 `SpringBoot` 程序的 `main` 方法类并不是自己写的类，而是 `SpringBoot` 的启动入口类 `org.springframework.boot.loader.JarLauncher`。
- `SERVICE_DESC`：服务描述信息，填写简短的描述服务功能作用等的信息，将被添加到 `service` 文件的 `Description` 中。
- `VERSION`：程序版本，填写程序的当前版本，将被用于程序更新判断，同版本程序更新将会失败。
- `INSTALL_PATH`：安装路径，服务的安装路径，默认值为 `/opt/$SERVICE_NAME`。
- `JAVA_HOME`：`JAVA_HOME` 环境变量，如果为空程序将自动尝试获取 `java` 位置。
- `JVM_OPTIONS`：`JVM` 参数，可以添加 `-Xmx`、`-Xms` 等 `JVM` 配置。
- `PROGRAM_ARGUMENTS`：`Jar` 程序参数，如果你的 `jar` 程序需要某些自定义参数进行启动，将在此处添加配置。
- `LIB_PATH`：程序依赖文件，如果你的依赖某些文件，如配置文件，依赖了其他 `jar`，需要将这些目录、文件添加到当此处，使用相对路径，多个路径用 `,` 分隔。
- `COMMEND_NAME`：服务管理命令名称，服务安装成功后将添加一个管理命令，用于指定管理命令名称，不能和已有命令重名，默认管理命令名称与服务名称相同。除了使用管理命令进行管理，也可以根据服务名称使用 `systemctl` 命令进行 `service` 管理。
