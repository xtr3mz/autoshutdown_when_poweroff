#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiIPAddress.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Inet.au3>
#include <TrayConstants.au3>

HotKeySet("{ESC}", "_Exit1")

$Form1 = GUICreate("PowerMonitor", 380, 90, 265, 254)
$lb1 = GUICtrlCreateLabel("Label2", 8, 8, 280, 45)
$lb2 = GUICtrlCreateLabel("Press ESC quit" & " / " & "Stop Monitor", 280, 5, 100, 45)
$pgs1 = GUICtrlCreateProgress(8, 58, 364, 25)

;GUICtrlSetBkColor($lb1,0x008000)
;GUICtrlSetFont($lb1, 22, 400, 0, "微软雅黑")
GUICtrlSetColor($lb1, 0x008000)
;GUICtrlSetFont($lb2, 14, 400, 0, "微软雅黑")
GUICtrlSetLimit($pgs1, 10, 0)
GUISetState(@SW_SHOW) 
TrayTip("Monitoring","Power moniter",0,$TIP_ICONASTERISK)

monitor()

Func monitor()
   Local $i = 0
   Local $cd=40;
   While $i < $cd ; $i <15s -> recheck else  shutdown
	  isConnect3()
		If isConnect1() Then
			$i =  0
			GUISetState(@SW_HIDE) ;hide GUI
			GUICtrlSetData($lb1,"Normal" )
			GUICtrlSetColor($lb1, 0x008000);green/绿色
			GUICtrlSetData($pgs1, 0)
		Else
		   $i = $i + 1
		   GUISetState(@SW_SHOW) ;show GUI
		   GUICtrlSetData($lb1,"Shutting Down in "& ($cd-$i) &"sec" )
		   GUICtrlSetColor($lb1, 0xFF0000);red/红色
		   GUICtrlSetData($pgs1, $i/$cd*100)
		   ;Beep(500, 1000)
		   _active()
		EndIf
	  Sleep(1000)
   WEnd
   ;$i==15
   Beep(500, 1000);freq=500 duration =1000
   Shutdown(8) ;1=shutdown  8=poweroff
EndFunc

Func _Exit1()
   Exit
EndFunc

Func _active()
   $title = WinGetTitle("Power Monitor")
   WinSetOnTop($title, "", 1)
   ;one of the above actions
   WinActivate($title)
EndFunc

;check internet connection / 无连接才报
Func isConnect1()
   Local Const $NETWORK_ALIVE_LAN = 0x1 ;net card connection
   Local Const $NETWORK_ALIVE_WAN = 0x2 ;RAS (internet) connection
   Local Const $NETWORK_ALIVE_AOL = 0x4 ;AOL
   Local $aRet, $iResult="",$rs=1
   $aRet = DllCall("sensapi.dll", "int", "IsNetworkAlive", "int*", 0)
   If BitAND($aRet[1], $NETWORK_ALIVE_LAN) Then $iResult &= "LAN connected" & " / "
   If BitAND($aRet[1], $NETWORK_ALIVE_WAN) Then $iResult &= "WAN connected" & " / "
   If BitAND($aRet[1], $NETWORK_ALIVE_AOL) Then $iResult &= "AOL connected" & " / "
   If($iResult = "") then
		 $rs=0;
   EndIf
   ConsoleWrite("["&@MIN &":"& @SEC &"]CONNECT1: "  & $rs & "(" &  $iResult & ")" & @LF)
   Return $iResult
EndFunc

;net cable is connect&powered but internet is not, also true / 有连接但无网时也true
Func isConnect2()
   Local $aReturn = DllCall('connect.dll', 'long', 'IsInternetConnected')
   If @error Then
	  Return SetError(1, 0, False)
   EndIf
   ConsoleWrite("["&@MIN & ":" & @SEC &"]CONNECT2: " &$aReturn[0] & @LF
   Return $aReturn[0]
EndFunc

;rounter is powered, without internet also true / 连路由 没有网也是true
Func isConnect3()
   $INTERNET_CONNECTION_MODEM          = 0x1
   $INTERNET_CONNECTION_LAN            = 0x2
   $INTERNET_CONNECTION_PROXY          = 0x4
   $INTERNET_CONNECTION_MODEM_BUSY     = 0x8
   $INTERNET_RAS_INSTALLED             = 0x10
   $INTERNET_CONNECTION_OFFLINE        = 0x20
   $INTERNET_CONNECTION_CONFIGURED     = 0x40

   $ret = DllCall("WinInet.dll","int","InternetGetConnectedState","int_ptr",0,"int",0)
   Local $rs=0
   Local $sX
   If $ret[0] then
      ;check type of connection
      $rs = 1;Connected
      If BitAND($ret[1], $INTERNET_CONNECTION_MODEM)      Then $sX &= "MODEM" & " / "
      If BitAND($ret[1], $INTERNET_CONNECTION_LAN)        Then $sX &= "LAN" & " / "
      If BitAND($ret[1], $INTERNET_CONNECTION_PROXY)      Then $sX &= "PROXY" & " / "
      If BitAND($ret[1], $INTERNET_CONNECTION_MODEM_BUSY) Then $sX &= "MODEM_BUSY" & " / "
      If BitAND($ret[1], $INTERNET_RAS_INSTALLED)         Then $sX &= "RAS_INSTALLED" & " / "
      If BitAND($ret[1], $INTERNET_CONNECTION_OFFLINE)    Then $sX &= "OFFLINE" & " / "
      If BitAND($ret[1], $INTERNET_CONNECTION_CONFIGURED) Then $sX &= "CONFIGURED" & " / "
   Else
      $rs = 0;"Not Connected"
   Endif
   ConsoleWrite("["&@MIN & ":" & @SEC &"]CONNECT3: " & $rs & "(" & $sX & ")" & @LF)
   return $rs;
EndFunc
