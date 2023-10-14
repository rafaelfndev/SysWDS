Pause

ServerManagerCmd -install WDS

WDSUTIL /Initialize-Server /RemInst:C:\RemoteInstall

wdsutil /Set-Server /DHCPOption60:No
wdsutil /Set-Server /UseDHCPPorts:No

net start WDSServer

wdsutil /Set-Server /DHCPOption60:Yes
wdsutil /Set-Server /UseDHCPPorts:Yes

SET PASTAX86=C:\RemoteInstall\Boot\x86
SET PASTAX64=C:\RemoteInstall\Boot\x64

copy %PASTAX86%\pxeboot.n12 %PASTAX86%\pxeboot.0
copy %PASTAX86%\abortpxe.com %PASTAX86%\abortpxe.0

copy core\pxelinux.0 %PASTAX86%\pxelinux.0
copy com32\menu\vesamenu.c32 %PASTAX86%\vesamenu.c32
copy com32\modules\chain.c32 %PASTAX86%\chain.c32

copy %PASTAX86%\pxelinux.0 %PASTAX86%\pxelinux.com

copy %PASTAX64%\pxeboot.n12 %PASTAX64%\pxeboot.0
copy %PASTAX64%\abortpxe.com %PASTAX64%\abortpxe.0

copy core\pxelinux.0 %PASTAX64%\pxelinux.0
copy com32\menu\vesamenu.c32 %PASTAX64%\vesamenu.c32
copy com32\modules\chain.c32 %PASTAX64%\chain.c32

copy %PASTAX64%\pxelinux.0 %PASTAX64%\pxelinux.com

MD %PASTAX86%\pxelinux.cfg
MD %PASTAX86%\Arquivos_e_ISOS\Ferramentas
MD %PASTAX86%\Arquivos_e_ISOS\Sistemas\Thinstation

MD %PASTAX64%\pxelinux.cfg
MD %PASTAX64%\Arquivos_e_ISOS\Ferramentas
MD %PASTAX64%\Arquivos_e_ISOS\Sistemas\Thinstation

xcopy _Arquivos\Ferramentas %PASTAX86%\Arquivos_e_ISOS\Ferramentas /E
xcopy _Arquivos\Ferramentas %PASTAX64%\Arquivos_e_ISOS\Ferramentas /E

MD %PASTAX86%\Arquivos_e_ISOS\ISOS
MD %PASTAX64%\Arquivos_e_ISOS\ISOS

copy _Arquivos\ISOS\iso_exemplo.iso %PASTAX86%\Arquivos_e_ISOS\ISOS\iso_exemplo.iso
copy _Arquivos\ISOS\iso_exemplo.iso %PASTAX64%\Arquivos_e_ISOS\ISOS\iso_exemplo.iso

copy _Arquivos\background.png %PASTAX86%
copy _Arquivos\memdisk %PASTAX86%

copy _Arquivos\background.png %PASTAX64%
copy _Arquivos\memdisk %PASTAX64%

copy _Arquivos\default  %PASTAX86%\pxelinux.cfg\default
copy _Arquivos\graphics.conf  %PASTAX86%\pxelinux.cfg\graphics.conf

copy _Arquivos\default  %PASTAX64%\pxelinux.cfg\default
copy _Arquivos\graphics.conf  %PASTAX64%\pxelinux.cfg\graphics.conf

wdsutil /set-server /bootprogram:boot\x86\pxelinux.com /architecture:x86
wdsutil /set-server /N12bootprogram:boot\x86\pxelinux.com /architecture:x86
wdsutil /set-server /bootprogram:boot\x64\pxelinux.com /architecture:x64
wdsutil /set-server /N12bootprogram:boot\x64\pxelinux.com /architecture:x64

WDSUTIL /Set-Server /pxepromptpolicy /new:NoPrompt
WDSUTIL /Set-Server /pxepromptpolicy /known:NoPrompt

wdsutil /set-server /answerclients:All

pause

