以下所有模块几乎都分为`知识`、`部署`、`使用`，

- 知识一般会链接到其他文档，
- 部署一般都是使用 Docker，会给到命令，
- 使用一般都是通过 SpringBoot 写一个测试例，但是不会很麻烦。所以可以提前准备好一个 SpringBoot 应用

## SpringBoot AOP

### 知识

#### AOP

- AOP（Aspect Oriented Programming）面向切面编程，是对面向对象编程的补充

- AOP可以在不修改功能代码的前提下，使用运行时动态代理的技术对已有代码逻辑进行增强

####  Spring AOP

Spring AOP 主要使用动态代理技术来实现，如果是被代理的类实现了接口，则使用JDK动态代理，如果被代理的类没有实现接口，则使用CGLIB进行代理

##### 代理形式

###### JDK动态代理

JDK动态代理，字面理解，就是Java提供的一种动态生成对象代理的机制，它允许在运行时创建一个实现了指定接口的代理类。本质就是在使用Java的反射机制，生成一个基于接口的代理类，这个代理类包含了对原始方法的调用，进而运营开发在前后添加自定义逻辑

至于性能的话，因为使用的是反射，所以在创建时会相对较慢，但是在方法调用时，因为直接调用了接口方法，所以性能较好

###### CGLIB

CGLIB是代码生成类库，CGLIB代理通过生成业务类的子类作为代理类，从而实现对目标对象的功能拓展，（基于ASM框架，ASM框架是一个Java字节码操控和分析框架，它允许开发者以二进制形式修改已有类或者动态生成类）

### 使用

#### maven

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-aop</artifactId>
</dependency>

<dependency>
    <groupId>org.aspectj</groupId>
    <artifactId>aspectjtools</artifactId>
</dependency>
```

#### Java Code

aop 需要确定自己的使用场景，以下举例是针对 api 下的接口增加统一日志打印如耗时统计

##### 注解

```java
package com.nanchaos.tech.config.aop.ann;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Default Description
 *
 * @author nanchaos
 * @date 2025/1/8
 * @time 09:53
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface AppInterfaceLog {

    /**
     * 是否将入参和返回 打印为 json 建议仅调试时使用
     */
    boolean printJSON() default false;

    /**
     * 接口告警阈值
     * 该大于该值时，more than limit:{}打印为 true
     */
    long alarmThreshold() default 300L;

    /**
     * 当接口异常时，，若为 true，返回默认结构的 error response, 为 false 返回为 null
     */
    boolean useDefaultErrorResp() default true;
}

```



##### 切面

以下定义了两个切点，

`@Pointcut("execution(* com.nanchaos.tech.service..*(..))")`

- 是把切点放在 tech.service 下的所有方法

`@annotation(com.nanchaos.tech.config.aop.ann.AppInterfaceLog)`

- 把切点放在注解上

`@Around("pointcutService()|| pointcutAppInterfaceLog()")`

- 表示只要命中其中一个，就会走到切面代码里，从左往右匹配

```Java
package com.nanchaos.tech.config.aop;

import com.alibaba.fastjson.JSON;
import com.nanchaos.tech.config.aop.ann.AppInterfaceLog;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.Signature;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.stereotype.Component;
import org.springframework.util.StopWatch;

import java.util.Objects;

/**
 * Default Description
 *
 * @author nanchaos
 * @date 2025/1/8
 * @time 09:53
 */
@Slf4j
@Aspect
@Component
public class AppInterfaceLogAdvice {

    @Pointcut("execution(* com.nanchaos.tech.service..*(..))")
    public void pointcutService() {
    }

    @Pointcut("@annotation(com.nanchaos.tech.config.aop.ann.AppInterfaceLog)")
    public void pointcutAppInterfaceLog() {
    }

    @Around("pointcutService()|| pointcutAppInterfaceLog()")
    public Object around(ProceedingJoinPoint joinPoint) {
        log.info("AppInterfaceLogAdvice.around.start");

        // traceLogId替换为网关trace，若非网关请求使用uuid生成trace，实现略。。。
        // 耗时监控
        StopWatch stopWatch = new StopWatch();
        stopWatch.start();

        Object result = null;
        boolean isPrintAsJson = false, useDefaultErrorResp = false;
        long alarmThreshold = 300L;
        String methodName = "UNKNOWN", className = null;
        Signature signature = joinPoint.getSignature();
        MethodSignature methodSignature = (MethodSignature) signature;

        if (methodSignature != null) {
            AppInterfaceLog annotation = methodSignature.getMethod().getAnnotation(AppInterfaceLog.class);
            if (annotation != null) {
                alarmThreshold = annotation.alarmThreshold();
                isPrintAsJson = annotation.printJSON();
                useDefaultErrorResp = annotation.useDefaultErrorResp();
            }
            className = joinPoint.getTarget().getClass().getName();
            methodName = methodSignature.getName();
        }

        log.info("AppName AppInterfaceLogAdvice.around.process, current is {}.{}, threadHold is:{}, args is:{}", className, methodName, alarmThreshold, isPrintAsJson ? JSON.toJSONString(joinPoint.getArgs()) : joinPoint.getArgs());

        try {
            result = joinPoint.proceed();
            log.info("AppName AppInterfaceLogAdvice.around.finish, current is {}.{}", className, methodName);
        } catch (Throwable throwable) {
            // 使用标准错误返回，实现略
            if (useDefaultErrorResp) result = null;
            log.error("AppName AppInterfaceLogAdvice.around.error, cause:{}", ExceptionUtils.getStackTrace(throwable));
        }
        stopWatch.stop();
        log.info("AppName AppInterfaceLogAdvice.around.end, current is {}.{}, time used:[{}ms], is more than limit:{}, result is:{}", className, methodName, stopWatch.getTotalTimeMillis(), stopWatch.getTotalTimeMillis() > alarmThreshold, result);
        return result;
    }
}

```



## SpringBoot With MySQL

### 部署

#### By Docker

> 如果是云服务器，记得防火墙设置

```shell
# 创建MySQL容器 注意替换yourpassword， 可以加上--restatrt always 以打开Docker
docker run -di --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=Nanchaos@1 mysql
docker run -di --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=yourpassword mysql

# 上面已创建完成，但是mysql 8以后不能使用 root 账户远程登录，所以单独创建一个用户专门用来远程登录
# 进入容器
docker exec -it mysql /bin/bash
 
# 登入mysql
mysql -u root -p
 
# 创建远程访问用户
CREATE USER 'remoteAccount'@'%' IDENTIFIED BY 'remotePassword';
 
# 授权
grant all privileges on *.* to 'remoteAccount'@'%' with grant option; 

# 刷新权限
flush privileges;

# 其他可能用到的
# 1. docker 导入数据文件
## 复制文件到 docker mysql内，这里的 mysql 是容器的名称，可以使用 id 替换
docker cp /你的目录/xxx.sql mysql:/
## 登录 并刷数据
msyql -u root -p
source /xxx.sql
```

![image-20250108170234612](./assets/image-20250108170234612.png)

## SpringBoot With Redis

### 知识

此处不做具体展开，详细参照 [Redis 知识](../中间件/Redis.md)

### 部署

#### By Docker

```shell
#:7.4.2是，指定版本，此时 redis 有 8 的 alpine 版本，所以指定为7.4.2
docker run --name chaos-redis -p 6379:6379 -d redis:7.4.2
```

### 使用

#### maven

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
```

#### application.yml

```yaml
spring:
  redis:
    host: redis.nanchaos.com
    port: 6379
```

#### Java Code

```java
package com.nanchaos.tech.redis;

import com.nanchaos.tech.TechValidationApplication;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.redis.core.StringRedisTemplate;

import javax.annotation.Resource;

/**
 * Default Description
 *
 * @author nanchaos
 * @date 2025/1/8
 * @time 17:21
 */
@Slf4j
@SpringBootTest(classes = TechValidationApplication.class)
public class RedisTest {
    @Resource
    private StringRedisTemplate stringRedisTemplate;

    @Test
    public void testAdd(){
        // 对应 redis-cli: SET REDIS_KEY 'this is redis value'
        stringRedisTemplate.opsForValue().set("REDIS_KEY", "this is redis value");
    }

    @Test
    public void testGet(){
        // 对应 redis-cli: GET REDIS_KEY
        stringRedisTemplate.opsForValue().get("REDIS_KEY");
    }
}

```



## SpringBoot With Elasticsearch

### 知识

> ElasticSearch支持JDBC协议，但是需要白金版（platinum）才能使用SQL，如果想使用 DataGrip连接ES，就需要使用白金版

### 部署

⚠️ 注意：Spring 和 ES 有版本对应关系，具体关系，如下: [Spring and ES 版本对应关系](https://docs.spring.io/spring-data/elasticsearch/reference/elasticsearch/versions.html)，目前部署的是 `ES 7.17.26`，使用 `SpringBoot 2.7.x`，使用的 Kibana 也是同 ES`7.17.26`版本

![image-20250114151408072](./assets/image-20250114151408072.png)

#### By Docker

```shell
docker network create elastic

# elasticsearch
docker pull docker.elastic.co/elasticsearch/elasticsearch:7.17.26
docker run --name es01 --net elastic -p 9200:9200 -p 9300:9300 -it -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:7.17.26

# kibana
docker pull docker.elastic.co/kibana/kibana:7.17.26
docker run --name kib01 -e ELASTICSEARCH_HOSTS=http://es01:9200 --net elastic -p 5601:5601 docker.elastic.co/kibana/kibana:7.17.26
```

![image-20250114155008852](./assets/image-20250114155008852.png)

#### 问题

##### 01、 ES重置密码

> ES 重置密码后，原本的 Kibana 可能会连不上ES，参照问题 2 修改kibana配置文件

```shell
# ES 7.x 重置 es 密码 可以换为 interactive 来手动设置密码
# 01 进入容器
docker exec -it es01 /bin/bash

# 02 修改 /usr/share/elasticsearch/config/elasticsearch.yml,添加以下内容
http.cors.enabled: true
http.cors.allow-origin: "*"
http.cors.allow-headers: Authorization
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true

# 添加后需要重启容器
docker restart es01

# 03 重置 es 密码 
./bin/elasticsearch-setup-passwords interactive
# bin/elasticsearch-setup-passwords auto|interactive

# ES 8 以后可以直接用这个
docker exec -it es01 /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic
docker exec -it es01 /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana
```



##### 02、 Kibana提示Server is not yet

```shell
# 01 进入容器
docker exec -it kib01 /bin/bash

# 02 改 /usr/share/kibana/config/kibana.yml ，添加以下内容
# 因为在同一网络下，es01就是 ES 容器的名称
elasticsearch.hosts: [ "http://es01:9200" ]
monitoring.ui.container.elasticsearch.enabled: true
# set language to chinese
i18n.locale: "zh-CN"
# 以下这两行，配了不会实际用，不配就会Kibana server is not ready yet，没有深究
elasticsearch.username: "elastic"
elasticsearch.password: "Nanchaos@1"
```



### 使用
