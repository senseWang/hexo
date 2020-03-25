---
title: 04-for循环的各个语句及list列表学习
date: 2020-03-07 09:11:12
banner_img: https://sense-1301203133.cos.ap-beijing.myqcloud.com/homepahe/%E6%96%87%E7%AB%A0-python-%E5%9F%BA%E7%A1%80-%E4%BC%81%E9%B9%85.jpg
index_img: http://q6vldn2n0.bkt.clouddn.com/%E9%9D%99%E5%9B%BE%20%284%29.jpg
tags:
- Python基础
categories:
- Python基础
---

## 04-for循环的各个语句及list列表学习



### 1. for循环

* **根据传入的序列进行循环，每次循环都会将序列中的一个元素引出成变量，序列变量完成，循环结束。**

* **格式：**

  ```
  # 普通for循环
  for <var> in <seq>: 			# var为变量，接收每次循环序列引出的元素；seq为序列
      语句1						# 每次循环时执行的语句
      
  # for-else语句格式:
  for <var> in <seq>:
      语句1
  else:
      语句2							# 当for循环正常结束，执行此语句，不包括break
  ```



### 2. range()函数

* **range函数根据所传参数来生成数列，可以被for循环使用**

* **range函数也可以被其他函数调用，如list、tuple等**

* **实例:**

  ```
  # for 循环调用
  for i in range(-10,10,2):		#生成一个从-10开始，步长为2，到10结束的数列，不包括10
      print(i)
  
  # list函数调用
  In [1]: list(range(10))			# 会生成一个从0到9的列表
  Out[1]: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  ```



### 3. 循环语句中的break、continue、pass

* **break: break语句用于终止当前的while或for循环，而且循环对应的else语句也不会被执行**

* **continue: 用于跳过此次循环中后面的所有语句，继续下一轮循环**

* **pass: 占位符，在循环中为空语句，不会做任何事，只是为了保证程序的完整性**

  ****

* **break语句实例:**

  ```
  # 遍历字符串"sense",但只遍历到"n"
  
  # 1. for 循环
  for i in "sense":
      print(i)
      if i == "n":
          break
          
  # 2. while 循环
  str1 = "sense"
  index = 0
  while True:
      print(str1[index])
      if str1[index] == "n":
          break
      index += 1
  
  输出：
  s
  e
  n
  ```

* **continue语句实例:**

  ```
  # 1. for循环     # 遍历字符串"sense",但要跳过"n"
  for i in "sense":
      if i == "n":
          continue
      print(i)
      
  输出：
  s
  e
  s
  e
      
  # 2. while循环   # 打印1~5，但是不能包括3
  num1 = 0
  while num1 < 5:
      num1 += 1              
      if num1 == 3:
          continue
      print(num1)
      
  输出：
  1
  2
  4
  5
  ```

* pass语句实例

  ```
  for i in "sense":
      if i == "n":
          pass			#照常运行，什么事都不做
      print(i)
      
  输出：
  s
  e
  n
  s
  e
  ```

### 4. list列表

* 含义：将多个元素放到一个序列中存储；其元素在list中是有序的

* 特点：每个元素都有下标，方便获取；而且元素可以为不同类型

  ```
  """
    创建列表的格式
    格式：列表名 = [列表选项1, 列表选项2, ...., 列表选项n]
  """
  
  # 创建含有多种数据类型的列表
  [1,"2",[1,2],True]
  ```

* 列表元素访问及二维列表(使用下标方法)：

  ```
  # 格式：  列表名[下标]
  list1 = [1,2,3]
  list1[1]          #取第二个元素
  
  # 二维列表,取其中的6
  In [1]: twoList = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  In [2]: twoList[1][2]
  Out[2]: 6
  ```

* 元素的替换：

  ```
  # 将列表中的2替换成1
  In [1]: list1 = [1,2,3]
  In [2]: list1[1] = 1
  In [3]: list1
  Out[3]: [1, 1, 3]
  ```

* 列表组合与重复

  ```
  # 列表重复
  In [4]: list4 = [1, 2, 3]
  In [5]: list5 = [4, 5, 6]
  In [6]: list6 = list4+list5
  In [7]: list6
  Out[7]: [1, 2, 3, 4, 5, 6]
  
  # 列表重复
  In [8]: list7 = [1,2,3]
  In [9]: list8 = list7*3
  In [10]: list8
  Out[10]: [1, 2, 3, 1, 2, 3, 1, 2, 3]
  ```

* 成员运算符在列表中的使用及列表截取

  ```
  # 成员运算符的使用
  In [11]: list9 = [1,2,3,4,5]
  In [12]: 2 in list9
  Out[12]: True
  In [13]: 6 not in list9
  Out[13]: True
      
  # 列表截取，返回的时列表
  In [18]: list10 = [1, 2, 3, 4, 5, 6, 7, 8]
  In [19]: list10[3:6]
  Out[19]: [4, 5, 6]
  In [20]: list10[:]
  Out[20]: [1, 2, 3, 4, 5, 6, 7, 8]
  In [21]: list10[:-1]
  Out[21]: [1, 2, 3, 4, 5, 6, 7]
  In [22]: list10[::-1]
  Out[22]: [8, 7, 6, 5, 4, 3, 2, 1]
  ```

* 列表方法(通用函数)

  |   方法名   |           描述           |
  | :--------: | :----------------------: |
  | len(list)  |     返回列表元素个数     |
  | max(list)  |    返回列表元素最大值    |
  | min(list)  |    返回列表元素最小值    |
  | list(seq)  |     将序列转换为list     |
  | count(obj) | 返回列表中元素出现的次数 |

* 纯列表方法

  |        方法名         |                             描述                             |
  | :-------------------: | :----------------------------------------------------------: |
  |      append(obj)      |                    在列表末尾添加一个元素                    |
  |      extend(obj)      |           在列表末尾一次性追加另一个列表的多个元素           |
  |   insert(index,obj)   |     在下标处添加一个元素，不覆盖原数据，原数据往后顺延。     |
  |      pop(index)       |          移除列表中指定下标处的元素,默认为最后一个           |
  |      remove(obj)      |      按照元素名移除，移除列表中的某一个元素，匹配第一个      |
  |        clear()        |                    *清除列表中的所有元素*                    |
  | index(obj,start,stop) |     从列表中找出某个元素的下标，匹配第一个,可以指定范围      |
  |       reverse()       |                          将列表倒序                          |
  |  sort(reverse=False)  |         将列表元素按大小升序,reverse为False时为升序          |
  |        copy()         | 深拷贝列表，拷贝后两列表互不干扰，浅拷贝直接使用赋值运算符即可 |



### 5. 列表生成式

* **使用python的内置功能来简单的创建出想要的list**

```
# range: 生成指定范围内的list
In [2]: list(range(1,10))
Out[2]: [1, 2, 3, 4, 5, 6, 7, 8, 9]
In [3]: list(range(1,10,2))
Out[3]: [1, 3, 5, 7, 9]

# 真正的列表生成式
# 取0到10
In [4]: [i for i in range(10)]
Out[4]: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

# 取0~10之间能被2整除的数
In [5]: [i for i in range(10) if i % 2 == 0]
Out[5]: [0, 2, 4, 6, 8]

# 取0~10之间所有数的平方
In [6]: [i*i for i in range(10)]
Out[6]: [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]

# 取另一个列表中大于0的数
In [10]: list1 = [0, 2, -3, -4, 5]
In [11]: list2 = [i for i in list1 if i > 0]
In [12]: list2
Out[12]: [2, 5]
    
# 两个for循环
In [15]: [x+y for x in "ABC" for y in "XYZ"]
Out[15]: ['AX', 'AY', 'AZ', 'BX', 'BY', 'BZ', 'CX', 'CY', 'CZ']
    
# 根据ASCII值取a-z
In [23]: print([chr(x) for x in range(ord("a"),ord("z")+1)])
['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
```



### 6. 实例演练

```
# 使用while删除列表中重复的数字3
numList = [1, 2, 3, 3, 3, 4, 5, 6, 2, 4, 3, 3, "3", '3']
num1 = 0
times = numList.count(3)
while num1 < times:
    numList.remove(3)
    num1 += 1
print(numList)

# 写一个随机点名册
```




