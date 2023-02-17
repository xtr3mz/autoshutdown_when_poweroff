#coding:utf-8

import os
import sys
import threading
import time

vcount=0
vinterval=1
vmax=30 #30sec

def checknet():
    global timer,vinterval,vcount
    ip = '192.168.1.1'
    #ip = 'www.baidu.com'
    #-n 1指发送报文一次 /win7 use -n  >nul/ linux use -c >>dev/null
    backinfo =  os.system('ping -n 1 -w 1 '+ip+'>nul') 
    # 实现pingIP地址的功能 -w 1指等待1秒
    if backinfo==0:#good
        vcount=0  
        os.system("shutdown -a") #cancel
    else: #
        vcount=vcount-1
        print ('disconnected!',vcount)        
        if vcount <=-vmax:
            print ('shutting down')
            os.system("shutdown /s /t 1")
            timer.cancel()
    #重复构造定时器
    timer = threading.Timer(vinterval,checknet)
    timer.start()

#定时调度
timer = threading.Timer(vinterval,checknet)
timer.start()

# 50秒后停止定时器
time.sleep(50)
timer.cancel()
