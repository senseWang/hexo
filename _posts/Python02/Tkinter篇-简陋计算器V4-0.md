---
title: Tkinter篇--简陋计算器V4.0
date: 2020-03-07 09:07:44
banner_img: https://sense-1301203133.cos.ap-beijing.myqcloud.com/homepahe/%E6%96%87%E7%AB%A0-python-%E9%AB%98%E7%BA%A7-%E7%81%AF%E6%B3%A1.jpg
index_img: https://sense-1301203133.cos.ap-beijing.myqcloud.com/index-page/%E9%9D%99%E5%9B%BE%20%2811%29.jpg
tags:
- Python高级
categories:
- Python高级
---
**Tkinter篇--简陋计算器V4.0**


### 1. Tkinter是python常见的GUI工具之一，已经属于python内置模块
 

**功能介绍：**
<video src="https://sense-1301203133.cos.ap-beijing.myqcloud.com/sense-video/tkinter-%E7%AE%80%E9%99%8B%E8%AE%A1%E7%AE%97%E5%99%A8.mp4" width="690" height="390" controls="controls"></video>
-----

* 一个漂亮的窗口往往是各个部件组装起来的，tkinter中称为控件
* 常见的tkinter控件

| 控件名 | 描述                                               |
| ------ | -------------------------------------------------- |
| Button | 按钮控件；在程序中显示按钮。                       |
| Entry  | 输入控件；用于显示简单的文本内容                   |
| Frame  | 框架控件；在屏幕上显示一个矩形区域，多用来作为容器 |
| Label  | 标签控件；可以显示文本和位图                       |
| Menu   | 菜单控件；显示菜单栏,下拉菜单和弹出菜单            |
| Text   | 文本控件；用于显示多行文本                         |

* 有了这些控件，就可以按照自己喜欢的样式进行摆放
* tkinter中的布局管理：

| 方法  | 描述                                            |
| ----- | ----------------------------------------------- |
| pack  | 包装                                            |
| grid  | 网格                                            |
| place | 位置,个人推荐使用，可以根据坐标的x，y值进行布局 |

###  **2. 实例** 

```
import tkinter as tk
import tkinter.messagebox
import math
import re
from math import *
from time import sleep
from PIL import Image,ImageTk


class Calc(object):
    """此类用于定义各tkinter的控件"""

    # 初始化动作，用于加载主窗口
    def start(self):
        self.win = tk.Tk()
        self.win.title("Sense Calc")
        # 主窗口尺寸
        self.win.geometry("400x400+500+200")
        # 固定主窗口尺寸，因为是绝对布局，所以窗体的改变不会改变控件，因此会很难看
        self.win.resizable(0, 0)

    def entryFunc(self):
        """entry控件，主要用于写出表达式交给text控件计算"""

        # 给此控件中的文本内容进行绑定值，计算时get获取使用
        self.info = tk.Variable()
        # 给entry设置主窗口、大小等
        self.entry = tk.Entry(self.win, textvariable=self.info, bd=6, width=50)
        # 根据x、y轴布局
        self.entry.place(x=20, y=100)
        # 绑定entry中回车事件
        self.entry.bind("<Return>", funct.func)
        # 绑定entry中ctrl+l事件
        self.entry.bind("<Control-l>", funct.func2)
        # 绑定entry中Delete事件
        self.entry.bind("<Delete>", funct.func2)

    def buttonFunc(self):
        """按钮控件"""
        # 给按钮设置主窗口、文本、及对应命令
        button = tk.Button(self.win, text="计算", command=funct.func)
        button.place(x=120, y=150)
        button2 = tk.Button(self.win, text="清空", command=funct.func2)
        button2.place(x=240, y=150)

    def menuFunc(self):
        """菜单栏控件"""
        # 创建菜单栏并给菜单栏控件设置主窗口
        menubar = tk.Menu(self.win)
        # 给主窗口配置菜单栏
        self.win.config(menu=menubar)

        # 创建1级菜单栏实例，并指定主菜单栏
        menu1 = tk.Menu(menubar, tearoff=False)
        # 创建2级菜单，并指定对应的功能
        menu1.add_command(label="Hello", command=lambda :funct.func3(funct.mboxDict["intro"][0],funct.mboxDict["intro"][1]))
        menu1.add_command(label="World",command=lambda: funct.func3(funct.mboxDict["intro2"][0], funct.mboxDict["intro2"][1]))
        # 添加到1级菜单
        menubar.add_cascade(label="sense", menu=menu1)

        # 以下同上
        menu2 = tk.Menu(menubar, tearoff=False)
        menu2.add_command(label="快捷键帮助", command=lambda : funct.func3(funct.mboxDict["help"][0],funct.mboxDict["help"][1]))
        menu2.add_command(label="版本", command=lambda : funct.func3(funct.mboxDict["version"][0],funct.mboxDict["version"][1]))
        menubar.add_cascade(label="help", menu=menu2)

        menu3 = tk.Menu(menubar, tearoff=False)
        menu3.add_command(label="常见", command=lambda : funct.func3(funct.mboxDict["funcInfo2"][0],funct.mboxDict["funcInfo2"][1]))
        menu3.add_command(label="罕见", command=lambda : funct.func3(funct.mboxDict["funcInfo"][0],funct.mboxDict["funcInfo"][1]))
        menubar.add_cascade(label="功能大全", menu=menu3)

        menu4 = tk.Menu(menubar, tearoff=False)
        menu4.add_command(label="注册", command=lambda : funct.func3(funct.mboxDict["user"][0],funct.mboxDict["user"][1]))
        menu4.add_command(label="登录", command=money.main)
        menubar.add_cascade(label="账户", menu=menu4)

        menu5 = tk.Menu(menubar, tearoff=False)
        menu5.add_command(label="进制转换", command=aryviw1.main)
        menu5.add_command(label="CN大写转换", command=chinese.main)
        menubar.add_cascade(label="其他功能", menu=menu5)

    def endFunc(self):
        '''主窗口循环更新，大材小用了...'''
        self.entry.focus_set()
        self.win.mainloop()

    def main(self):
        """主程序，主要运行各方法"""
        try:
            chinese.cnWin.destroy()

        except:
            pass
        try:
            aryviw1.aryWin.destroy()
        except:
            pass
        self.start()
        self.menuFunc()
        self.entryFunc()
        self.buttonFunc()
        self.endFunc()


class MoneyView(object):
    """付费窗口类"""
    # 根据此变量来判断是否登录认证成功，默认为False
    auth = False

    def __init__(self):
        # 已有的账户
        self.userDict = {"wss": "123123", "sense": 123123}

    def startFunc(self):
        """主窗口"""
        self.root = tk.Tk()
        self.root.title("Sense 登录窗口")
        self.root.geometry("400x150+500+200")
        self.root.resizable(0, 0)

    def entryFunc(self):
        self.nameInfo = tk.Variable()
        self.nameEntry = tk.Entry(self.root, textvariable=self.nameInfo, bd=2, width=40)
        self.nameEntry.place(x=70, y=35)
        self.passwdInfo = tk.Variable()
        self.passwdEntry = tk.Entry(self.root, textvariable=self.passwdInfo, bd=2, width=40, show="$")
        self.passwdEntry.place(x=70, y=58)
        self.nameEntry.bind("<Return>", funct.login)
        self.passwdEntry.bind("<Return>", funct.login)

    def labelFunc(self):
        nameLable = tk.Label(self.root, text="用户:", font=("微软雅黑", 10))
        nameLable.place(x=25, y=33)

        passwdLable = tk.Label(self.root, text="密码:", font=("微软雅黑", 10))
        passwdLable.place(x=25, y=55)

        self.infoLable = tk.Label(self.root, text="登录成功！ 请稍后...", font=("微软雅黑", 12), fg="green")

    def buttonFunc(self):
        button = tk.Button(self.root, text="登录", command=funct.login)
        button.place(x=320, y=85)

    def endFunc(self):
        self.root.mainloop()

    def main(self):
        self.startFunc()
        self.labelFunc()
        self.entryFunc()
        self.buttonFunc()
        self.endFunc()


class AryView(object):

    def start(self):
        self.aryWin = tk.Tk()
        self.aryWin.title("Sense-进制转换")
        self.aryWin.geometry("500x260+500+200")
        self.aryWin.resizable(0,0)

    def entryFunc(self):
        self.binInfo = tk.Variable()
        self.entry1 = tk.Entry(self.aryWin, textvariable=self.binInfo, bd=3, width=55)
        self.entry1.place(x=70, y=30)
        self.entry1.bind("<Return>", funct.binResult)
        self.entry1.bind("<Control-l>", funct.aryClear)
        self.entry1.bind("<Delete>", funct.aryClear)
        self.entry1.bind("<Down>",funct.focus_oct)

        self.octInfo = tk.Variable()
        self.entry2 = tk.Entry(self.aryWin, textvariable=self.octInfo, bd=3, width=55)
        self.entry2.place(x=70, y=80)
        self.entry2.bind("<Return>", funct.octResult)
        self.entry2.bind("<Control-l>", funct.aryClear)
        self.entry2.bind("<Delete>", funct.aryClear)
        self.entry2.bind("<Up>", funct.focus_bin)
        self.entry2.bind("<Down>", funct.focus_dec)

        self.decInfo = tk.Variable()
        self.entry3 = tk.Entry(self.aryWin, textvariable=self.decInfo, bd=3, width=55)
        self.entry3.place(x=70, y=130)
        self.entry3.bind("<Return>", funct.decResult)
        self.entry3.bind("<Control-l>", funct.aryClear)
        self.entry3.bind("<Delete>", funct.aryClear)
        self.entry3.bind("<Up>", funct.focus_oct)
        self.entry3.bind("<Down>", funct.focus_hex)

        self.hexInfo = tk.Variable()
        self.entry4 = tk.Entry(self.aryWin, textvariable=self.hexInfo, bd=3, width=55)
        self.entry4.place(x=70, y=180)
        self.entry4.bind("<Return>", funct.hexResult)
        self.entry4.bind("<Control-l>", funct.aryClear)
        self.entry4.bind("<Delete>",funct.aryClear)
        self.entry4.bind("<Up>", funct.focus_dec)

    def lableFunc(self):
        binLable = tk.Label(self.aryWin, text="二进制", font=("微软雅黑", 10))
        binLable.place(x=22, y=30)

        octLable = tk.Label(self.aryWin, text="八进制", font=("微软雅黑", 10))
        octLable.place(x=22, y=80)

        decLable = tk.Label(self.aryWin, text="十进制", font=("微软雅黑", 10))
        decLable.place(x=22, y=130)

        hexLable = tk.Label(self.aryWin, text="十六进制", font=("微软雅黑", 10))
        hexLable.place(x=10, y=180)

    def buttonFunc(self):
        button1 = tk.Button(self.aryWin, text="转换", command=funct.allResult)
        button1.place(x=180, y=210)
        button2 = tk.Button(self.aryWin, text="清空", command=funct.aryClear)
        button2.place(x=300, y=210)

    def menuFunc(self):
        menubar = tk.Menu(self.aryWin)
        self.aryWin.config(menu=menubar)

        menu1 = tk.Menu(menubar, tearoff=False)
        menu1.add_command(label="Hello",
                          command=lambda: funct.func3(funct.mboxDict["intro"][0], funct.mboxDict["intro"][1]))
        menu1.add_command(label="World",
                          command=lambda: funct.func3(funct.mboxDict["intro2"][0], funct.mboxDict["intro2"][1]))
        menubar.add_cascade(label="sense", menu=menu1)

        menu2 = tk.Menu(menubar, tearoff=False)
        menu2.add_command(label="常规计算器",command=calc.main)
        menu2.add_command(label="CN大写转换",command=chinese.main)
        menubar.add_cascade(label="功能切换", menu=menu2)

    def endFunc(self):
        self.entry1.focus_set()
        self.aryWin.mainloop()

    def main(self):
        try:
            calc.win.destroy()
        except:
            pass
        try:
            chinese.cnWin.destroy()
        except:
            pass
        self.start()
        self.entryFunc()
        self.lableFunc()
        self.buttonFunc()
        self.menuFunc()
        self.endFunc()


class CNView(object):
    def start(self):
        self.cnWin = tk.Tk()
        self.cnWin.title("Sense-数字转换")
        self.cnWin.geometry("300x400+500+200")
        self.cnWin.resizable(0, 0)

    def bottonFunc(self):
        button1 = tk.Button(self.cnWin, text="1", bd=4, height=3,width=8,command=lambda : funct.numInsert(1))
        button1.place(x=0, y=190)
        button4 = tk.Button(self.cnWin, text="4", bd=4, height=3, width=8,command=lambda : funct.numInsert(4))
        button4.place(x=0, y=260)
        button7 = tk.Button(self.cnWin, text="7", bd=4, height=3, width=8,command=lambda : funct.numInsert(7))
        button7.place(x=0, y=330)
        button2 = tk.Button(self.cnWin, text="2", bd=4, height=3, width=8,command=lambda : funct.numInsert(2))
        button2.place(x=70, y=190)
        button5 = tk.Button(self.cnWin, text="5", bd=4, height=3, width=8,command=lambda : funct.numInsert(5))
        button5.place(x=70, y=260)
        button8 = tk.Button(self.cnWin, text="8", bd=4, height=3, width=8,command=lambda : funct.numInsert(8))
        button8.place(x=70, y=330)
        button3 = tk.Button(self.cnWin, text="3", bd=4, height=3, width=8,command=lambda : funct.numInsert(3))
        button3.place(x=140, y=190)
        button6 = tk.Button(self.cnWin, text="6", bd=4, height=3, width=8,command=lambda : funct.numInsert(6))
        button6.place(x=140, y=260)
        button9 = tk.Button(self.cnWin, text="9", bd=4, height=3, width=8,command=lambda : funct.numInsert(9))
        button9.place(x=140, y=330)
        button11 = tk.Button(self.cnWin, text="清空", bd=4, height=3, width=11,command=funct.CNClear)
        button11.place(x=210, y=190)
        button0 = tk.Button(self.cnWin, text="0", bd=4, height=3, width=11,command=lambda : funct.numInsert(0))
        button0.place(x=210, y=260)
        button12 = tk.Button(self.cnWin, text="转换", bd=4, height=3, width=11,command=funct.CNresult)
        button12.place(x=210, y=330)

    def entryFunc(self):
        self.entryInfo=tk.Variable()
        self.entry = tk.Entry(self.cnWin,textvariable=self.entryInfo,bd=6,width=30,font=10)
        self.entry.place(x=35,y=40)
        self.entry.bind("<Return>", funct.CNresult)
        self.entry.bind("<Control-l>", funct.CNClear)
        self.entry.bind("<Delete>", funct.CNClear)
        self.entryInfo2 = tk.Variable()
        self.entry2 = tk.Entry(self.cnWin,textvariable=self.entryInfo2,bd=6, width=30, font=10)
        self.entry2.place(x=35, y=100)

    def labelFunc(self):
        label = tk.Label(self.cnWin,text="数:",font=("楷体",15))
        label.place(x=-1,y=40)
        label2 = tk.Label(self.cnWin, text="汉:",font=("楷体",15))
        label2.place(x=-1, y=100)

    def menuFunc(self):
        menubar = tk.Menu(self.cnWin)
        self.cnWin.config(menu=menubar)
        menu1 = tk.Menu(menubar, tearoff=False)
        menu1.add_command(label="Hello",
                          command=lambda: funct.func3(funct.mboxDict["intro"][0], funct.mboxDict["intro"][1]))
        menu1.add_command(label="World",
                          command=lambda: funct.func3(funct.mboxDict["intro2"][0], funct.mboxDict["intro2"][1]))
        menubar.add_cascade(label="sense", menu=menu1)

        menu2 = tk.Menu(menubar, tearoff=False)
        menu2.add_command(label="常规计算器",command=calc.main)
        menu2.add_command(label="进制转换",command=aryviw1.main)
        menubar.add_cascade(label="功能切换", menu=menu2)

    def endFunc(self):
        self.cnWin.mainloop()

    def main(self):
        try:
            aryviw1.aryWin.destroy()
        except:
            pass
        try:
            calc.win.destroy()
        except:
            pass
        self.start()
        self.bottonFunc()
        self.entryFunc()
        self.labelFunc()
        self.menuFunc()
        self.endFunc()


class Func(object):
    """工具类，用于定义Calc类中对应的各个事件、行为"""

    def __init__(self):
        self.mboxDict = {"hint":["WARNING", "  输入有误!!!"],"help":["帮助信息-快捷键", "  ctrl+l or del  清屏\n\n  Enter  计算"],
                         "intro":["Sense Wang", "Sense is a handsome man!\nSense is nice good ... man!\n 多谢夸奖！！！"],
                         "intro2":["程序说明", "  此程序全名为简陋计算器，娱乐而已\n\n  功能丰富，感受Python语言的魅力"],
                         "funcInfo":["功能大全-罕见", "  acos(x)--->\t返回 x 的反余弦\n  acosh(x)--->\t返回 x 的反双曲余弦\n"
                                          "  asin(x)--->\t返回 x 的反正弦\n  asinh(x)--->\t返回 x 的反双曲正弦\n  atan(x)--->\t返回 x 的反正切"
                                          "\n  atan2(y,x)--->\t返回 y/x 的反正切\n  atanh(x)-->\t返回 x 的反双曲正切\n"
                                          "  cos(x)-->\t返回 x 的余弦\n  sin(x)-->\t\t返回 x 的正弦\n  tan(x)-->\t\t返回 x 的正切\n  "
                                          "copysign(x,y)-->\t返回与 y 同号的 x 值\n  sinh(x)-->\t返回 x 的双曲正弦\n  "
                                          "cosh(x)-->\t返回 x 的双曲余弦\n  radians(d)-->\t將 x(角度) 转成弧长，与 degrees 为反函数\n  "
                                          "degrees(x)-->\t将 x (弧长) 转成角度，与 radians 为反函数\n  "
                                          "frexp(x)-->\t返回参数x的二元组\n  isinf(x)-->\t如果是正负无穷大数返回True\n  "
                                          "isnan(x)-->\t如果不是数字返回True\n  ldexp(m,n)-->\t返回 m×2n与 frexp 是反函数\n  "
                                          "log(x,a)-->\t返回x的自然数对数,不写a内定e\n  log10(x)-->\t返回x的以10为底的对数\n  "
                                          "loglp(x)-->\t返回x+1的自然对数(基数为e)的值\n  tanh(x)-->\t返回 x 的双曲正切\n  "
                                          ""],
                         "funcInfo2":["功能大全-常见", "  ceil(x)-->\t返回≧ x 的最小整数\n  e-->\t\t常数 e = 2.7128...\n  "
                                          "exp(x)-->\t返回e的次方x也就是 math.e**x\n  abs(x)-->\t返回 x 的绝对值\n  "
                                          "factorial(x)-->\t返回x!,即阶乘\n  floor(x)-->\t返回≦ x 的最大整数\n  "
                                          "fmod(x,y)-->\t类型于%取模，但保留小数\n  fsum(x)-->\t返回 x 阵列值的各項和\n  "
                                          "hypot(x,y)-->\t返回x²+y²的开方\n  modf(x)-->\t返回 x 的小数部份与整数部份\n  "
                                          "pi-->\t\t常数π\n  pow(x,y)-->\t返回x的y次方\n  sqrt(x)-->\t给x开方\n  "
                                          "trunc(x)-->\t返回x的整数部分等同于int"],
                         "user":["账户注册", "  电话：15357611539\n\n  邮箱：sense_s_wang@163.com\n\n  QQ号：1695788151"],
                         "version":["Version", "简陋计算器-4.0"],
                         "hint2":["WARNING", "  输入有误!!!\n\n二进制单个数字中只能包含  0 ~ 1"],
                         "hint3":["WARNING", "  输入有误!!!\n\n八进制单个数字中只能包含  0 ~ 7"],
                         "hint4":["WARNING", "  输入有误!!!\n\n十进制进制单个数字中只能包含  0 ~ 9"],
                         "hint5":["WARNING", "  输入有误!!!\n\n十六进制进制单个数字中只能包含  0 ~ 9 | a ~ f"],
                         "hint6":["WARNING", "  输入有误!!!\n\n只能包含整数"]}

    def func(self, event=None):
        """形参event为绑定的事件"""
        # 获取entry中的文本内容
        info = calc.entry.get()
        # if money.auth:
        for i in dir(math):
            # 通过re模块查询是否使用了math模块，没有则返回None
            findInfo = re.search("%s" % i, info)
            if findInfo and not money.auth:
                # 此处为一个小bug修复，即如果选择不登录，也会计算
                calc.text.delete("1.0", 'end')
                moneyChoose = tk.messagebox.askyesno("付费内容", "此功能为付费功能\n\n是否登录？")
                if moneyChoose:
                    # 选择付费则进入登录页面
                    money.main()
                    return
                else:
                    return
            else:
                try:
                    # 计算的核心部分，计算字符串
                    result = eval(info)
                except:
                    # 提示窗口
                    choose = tk.messagebox.askretrycancel("WARNING", "  输入有误!!!")
                    if choose is False:
                        # 选择取消则关闭窗口
                        calc.win.destroy()
                    else:
                        # 选择重试则清空内容重试
                        self.func2()
                        return
                # text控件，计算后会显示结果
                calc.text = tk.Text(calc.win, width=20, height=2)
                calc.text.place(x=125, y=200)
                calc.text.tag_config("tag1", foreground="red", font=("Consolas", 20))
                calc.text.insert(tk.INSERT, result, "tag1")
                # text控件绑定的事件
                calc.text.bind("<Return>", self.func)
                calc.text.bind("<Control-l>", self.func2)
                calc.text.bind("<Delete>", self.func2)

    def func2(self, event=None):
        """此功能主要用于清空entry和text中的文本内容"""
        calc.entry.delete("0", tk.END)
        try:
            calc.text.delete("1.0", 'end')
        except AttributeError as e:
            pass

    def func3(self,titleInfo,mess):
        """提示窗体功能"""
        tk.messagebox.showinfo(titleInfo,mess)

    def login(self, event=None):
        """登录验证功能"""
        # 获取用户名
        name = money.nameEntry.get()
        # 获取密码
        passwd = money.passwdEntry.get()
        # 判断用户名是否存在，不存在则退出付费窗口
        if not money.userDict.get(name):
            tk.messagebox.showwarning("输入错误", "用户不存在")
            money.nameEntry.delete(0, "end")
            # destroy为关闭窗口
            money.root.destroy()
        # 因为没有键会产生异常
        try:
            # 判断密码是否正确
            if passwd == money.userDict[name]:
                # 修改验证为True已验证
                money.auth = True
                # 提示登录成功
                money.infoLable.place(x=100, y=100)
                # 更新窗口：update可以将lable控件更新出来，不然不会显示
                money.root.update()
                sleep(0.5)
                money.root.destroy()
            else:
                tk.messagebox.askretrycancel("输入错误", "密码错误！！！")
                money.nameEntry.delete(0, "end")
                money.root.destroy()
        except:
            pass

    def aryClear(self,event=None):
        aryviw1.entry1.delete("0", tk.END)
        aryviw1.entry2.delete("0", tk.END)
        aryviw1.entry3.delete("0", tk.END)
        aryviw1.entry4.delete("0", tk.END)

    def binResult(self,event=None):
        bin_s = aryviw1.entry1.get()
        try:
            dec_bin_s = int(bin_s, 2)
            oct_bin_s = oct(dec_bin_s).split("o")[1]
            hex_bin_s = hex(dec_bin_s).split("x")[1]
            aryviw1.entry2.delete("0",tk.END)
            aryviw1.entry2.insert(0,oct_bin_s)
            aryviw1.entry3.delete("0", tk.END)
            aryviw1.entry3.insert(0,dec_bin_s)
            aryviw1.entry4.delete("0",tk.END)
            aryviw1.entry4.insert(0,hex_bin_s)
        except:
            binChoose = tk.messagebox.askretrycancel(self.mboxDict["hint2"][0], self.mboxDict["hint2"][1])
            if binChoose is True:
                self.aryClear()

    def octResult(self,event=None):
        oct_s = aryviw1.entry2.get()
        try:
            dec_oct_s = int(oct_s, 8)
            bin_oct_s = bin(dec_oct_s).split("b")[1]
            hex_oct_s = hex(dec_oct_s).split("x")[1]
            aryviw1.entry1.delete("0", tk.END)
            aryviw1.entry1.insert(0,bin_oct_s)
            aryviw1.entry3.delete("0", tk.END)
            aryviw1.entry3.insert(0,dec_oct_s)
            aryviw1.entry4.delete("0", tk.END)
            aryviw1.entry4.insert(0,hex_oct_s)
        except:
            octChoose = tk.messagebox.askretrycancel(self.mboxDict["hint3"][0], self.mboxDict["hint3"][1])
            if octChoose is True:
                self.aryClear()

    def decResult(self,event=None):
        dec_s = aryviw1.entry3.get()
        try:
            bin_dec_s = bin(int(dec_s)).split("b")[1]
            oct_dec_s = oct(int(dec_s)).split("o")[1]
            hex_dec_s = hex(int(dec_s)).split("x")[1]
            aryviw1.entry1.delete("0", tk.END)
            aryviw1.entry1.insert(0,bin_dec_s)
            aryviw1.entry2.delete("0", tk.END)
            aryviw1.entry2.insert(0,oct_dec_s)
            aryviw1.entry4.delete("0", tk.END)
            aryviw1.entry4.insert(0,hex_dec_s)
        except:
            decChoose = tk.messagebox.askretrycancel(self.mboxDict["hint4"][0], self.mboxDict["hint4"][1])
            if decChoose is True:
                self.aryClear()

    def hexResult(self,event=None):
        hex_s = aryviw1.entry4.get()
        try:
            dec_hex_s = int(hex_s, 16)
            bin_hex_s = bin(dec_hex_s).split("b")[1]
            oct_hex_s = oct(dec_hex_s).split("o")[1]
            aryviw1.entry1.delete("0", tk.END)
            aryviw1.entry1.insert(0,bin_hex_s)
            aryviw1.entry2.delete("0", tk.END)
            aryviw1.entry2.insert(0,oct_hex_s)
            aryviw1.entry3.delete("0", tk.END)
            aryviw1.entry3.insert(0,dec_hex_s)
        except:
            hexChoose = tk.messagebox.askretrycancel(self.mboxDict["hint5"][0], self.mboxDict["hint5"][1])
            if hexChoose is True:
                self.aryClear()

    def allResult(self,event=None):
        # 通来判断光标在哪，来使用对应的方法
        focus = aryviw1.entry1.focus_get()
        focus_s = str(focus).split("!")[1]
        if focus_s == "entry":
            self.binResult()
        elif focus_s == "entry2":
            self.octResult()
        elif focus_s == "entry3":
            self.decResult()
        elif focus_s == "entry4":
            self.hexResult()

    def focus_bin(self,event=None):
        aryviw1.entry1.focus_set()

    def focus_oct(self,event=None):
        aryviw1.entry2.focus_set()

    def focus_dec(self,event=None):
        aryviw1.entry3.focus_set()

    def focus_hex(self,event=None):
        aryviw1.entry4.focus_set()

    def numInsert(self,num,event=None):
        chinese.entry.insert("end",num)

    def CNClear(self,event=None):
        chinese.entry.delete("0", tk.END)
        chinese.entry2.delete("0", tk.END)

    def CNresult(self,event=None):
        try:
            a = int(chinese.entry.get())
            digit = [u'零', u'壹', u'贰', u'叁', u'肆', u'伍', u'陆', u'柒', u'捌', u'玖']
            weight = [u'圆', u'拾', u'佰', u'仟', u'万', u'拾', u'佰', u'仟']
            Z = [(u'零仟', u'零佰', u'零拾', u'零零零', u'零零', u'零万', u'零圆'), (u'零', u'零', u'零', u'零', u'零', u'万', u'圆')]
            num = str(a)
            s = ''
            for i, x in enumerate(num):
                s += digit[int(x)] + weight[len(num) - i - 1]
            for z, v in zip(Z[0], Z[1]):
                s = s.replace(z, v)
            chinese.entry2.delete(0,"end")
            chinese.entry2.insert(0,s)
        except:
            self.func3(self.mboxDict["hint6"][0],self.mboxDict["hint6"][1])

def main():
    global funct,calc,money,aryviw1,chinese
    funct = Func()
    calc = Calc()
    money = MoneyView()
    aryviw1 = AryView()
    chinese = CNView()
    calc.main()
    # chinese.main()


if __name__ == '__main__':
    main()



```
