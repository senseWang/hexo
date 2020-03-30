---
title: sed对指定行添加或删除注释
date: 2020-03-26 11:30:50
banner_img: https://sense-1301203133.cos.ap-beijing.myqcloud.com/homepahe/%E6%96%87%E7%AB%A0-linux%E5%9F%BA%E7%A1%80-%E5%B7%A5%E4%BD%9C.jpg
index_img: https://sense-1301203133.cos.ap-beijing.myqcloud.com/index-page/%E9%9D%99%E5%9B%BE%20%2815%29.jpg
tags:
- Linux
- Linux基础
- sed
categories:
- Linux基础
---

### 	sed对指定行添加或删除注释


#### 示例文本如下：

```bash
[root@sense opt]# cat wang 
111111
222222
#222222
333333
11111
```

#### 添加注释:在包含111的行前添加

```bash
[root@sense opt]# sed 's/^111/#&/' wang 	  # &的意思是匹配任意字符（就是说未知数，啥都行）  这条命令是匹配111开头的
#111111
222222
#222222
333333
#11111
```

#### 去除注释：去除222前面的注释

```bash
[root@sense opt]# sed '/222/s/^#\(.*\)/\1/g' wang    #\1就是代表这个位置的内容，如果有第二个那么就\2就是代表第二个位置的内容
111111
222222
222222
333333
11111

#以下方法同上
[root@sense opt]# sed 's/^#222/222/' wang 
111111
222222
222222
333333
11111
```
