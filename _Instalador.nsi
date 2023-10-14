# ==================================================================
# Script NSIS para Instalação do SysLinux no Servidor Windows WDS
# ==================================================================

# Arquivos Necessarios para o NSIS

	!include MUI.nsh		
	!include LogicLib.nsh	
	!include WinVer.nsh	
	!include "FileFunc.nsh"
	!include "X64.nsh"
	!include "Sections.nsh"

	SetCompress Auto
	SetCompressor /SOLID lzma
	SetCompressorDictSize 32
	SetDatablockOptimize On
	
# Nivel necessario para instalação
	
	RequestExecutionLevel admin 	; none|user|highest|admin

# ==================================================================

	!define MUI_COMPONENTSPAGE_SMALLDESC ;No value (Define descrição na parte inferior)
	!define MUI_ICON "icone.ico"
	!define MUI_HEADERIMAGE
	!define MUI_HEADERIMAGE_BITMAP "_FILES\Imagens\top.bmp"
	!define MUI_WELCOMEFINISHPAGE_BITMAP "_FILES\Imagens\left.bmp"
	!define MUI_UNWELCOMEFINISHPAGE_BITMAP "_FILES\Imagens\left.bmp"

	!insertmacro MUI_PAGE_WELCOME
	!define MUI_LICENSEPAGE_CHECKBOX
	!insertmacro MUI_PAGE_LICENSE "license.txt"
	!insertmacro MUI_PAGE_COMPONENTS
	!insertmacro MUI_PAGE_DIRECTORY
	!insertmacro MUI_PAGE_INSTFILES
	!define MUI_FINISHPAGE_TEXT "Obrigado por instalar o SysWDS!\n\n\nPara mais informações visite o site:\n\nhttps://rafaelfndev.com.br/"
	!define MUI_FINISHPAGE_LINK "Doe! Contribua com o desenvolvimento de outros Utilitários!"
	!define MUI_FINISHPAGE_LINK_LOCATION "https://rafaelfndev.com.br/doar"
	;!define MUI_FINISHPAGE_RUN "explorer C:"
	;!define MUI_FINISHPAGE_RUN_TEXT "Abrir o diretório onde esta instalado o WDS"
	!insertmacro MUI_PAGE_FINISH
	!define MUI_ABORTWARNING

# ==================================================================

	!insertmacro MUI_LANGUAGE "Portuguese"	

	OutFile SysWDS.exe
	
	Name "SysWDS"
	
	Caption "SysLinux WDS"
	
	BrandingText "Instalação do SysLinux para Windows Deployment Services"	

	; Configurações
	InstallDir "C:\RemoteInstall"
	AutoCloseWindow false
	ShowInstDetails show
	SetOverwrite try
	Icon icone.ico	
	CRCCheck on		
	XPStyle on
	
Function .onInit
	MessageBox MB_OK|MB_ICONINFORMATION "Este software foi desenvolvido para ser instalado nas seguintes versões do Windows (x86 e x64):$\n$\n\
	Server 2003 R2 com SP2, Server 2008, Server 2008 R2 e Server 2012$\n$\n\
	Caso você não esteja utilizando nenhuma destas versões do Windows, é recomendavel cancelar a instalação."
FunctionEnd
	
	
SectionGroup "WDS (Windows Deployment Services)"

	Section "Instalar WDS"
	
		; Desabilita o redirecionamento em Sistemas x64
		${DisableX64FSRedirection}
		
		SetDetailsPrint both
		DetailPrint "•   O serviço WDS será instalado, aguarde..."	
		DetailPrint "     Instalando WDS"	
		SetDetailsPrint none
		; Server 2003 R2 SP2
		nsExec::Exec "cmd /c ECHO [Components] > %WINDIR%\InstallWDS.inf"
		nsExec::Exec "cmd /c ECHO RemInst = on >> %WINDIR%\InstallWDS.inf"
		nsExec::Exec "Sysocmgr.exe /i:sysoc.inf /u:%WINDIR%\InstallWDS.inf /r /q"
		; Server 2008 e 2008 R2
		nsExec::Exec "ServerManagerCmd -install WDS"
		; Server 2012
		nsExec::Exec "powershell Install-WindowsFeature WDS"
		
		SetDetailsPrint both
		DetailPrint "     Criando pastas do WDS"
		SetDetailsPrint none	
		nsExec::Exec "WDSUTIL /Initialize-Server /RemInst:$INSTDIR"
		
		SetDetailsPrint both
		DetailPrint "     Alterando porta DHCP para iniciar o Serviço"
		SetDetailsPrint none
		nsExec::Exec "wdsutil /Set-Server /DHCPOption60:No"
		nsExec::Exec "wdsutil /Set-Server /UseDHCPPorts:No"
		
		SetDetailsPrint both
		DetailPrint "     Iniciando Serviço do WDS"
		SetDetailsPrint none	
		nsExec::Exec "net start WDSServer"
		
		SetDetailsPrint both
		DetailPrint "     Configurando o uso da porta DHCP com o WDS"
		SetDetailsPrint none
		nsExec::Exec "wdsutil /Set-Server /DHCPOption60:Yes"
		nsExec::Exec "wdsutil /Set-Server /UseDHCPPorts:Yes"
		
	SectionEnd
	
	
	SectionGroup "Configurações do PXE (Selecione apenas uma)"
	
		Section /o "Não responder a nenhum computador"
		SetDetailsPrint both
		DetailPrint "     PXE: Não responder a nenhum computador"	
		SetDetailsPrint none
		${DisableX64FSRedirection}
		nsExec::Exec "wdsutil /set-server /answerclients:None"
		SectionEnd
		
		Section /o "Responder apenas computadores conhecidos"
		SetDetailsPrint both
		DetailPrint "     PXE: Responder apenas computadores conhecidos"	
		SetDetailsPrint none
		${DisableX64FSRedirection}
		nsExec::Exec "wdsutil /set-server /answerclients:Known"
		SectionEnd
			
		Section "Responder a todos os computadores"
		SetDetailsPrint both
		DetailPrint "     PXE: Responder a todos os computadores"	
		SetDetailsPrint none
		${DisableX64FSRedirection}
		nsExec::Exec "wdsutil /set-server /answerclients:All"
		SectionEnd
		
	SectionGroupEnd


	SectionGroup "Configurações de boot dos computadores"
	
		SectionGroup "Clientes conhecidos (Selecione apenas uma)"
			
			Section /o "Necessário apertar F12 para dar boot via rede"
			SetDetailsPrint both
			DetailPrint "     Boot de PCs Conhecidos: Necessário apertar F12 para dar boot via rede"	
			SetDetailsPrint none
			${DisableX64FSRedirection}
			nsExec::Exec "WDSUTIL /Set-Server /pxepromptpolicy /known:OptIn"
			SectionEnd
			
			Section "Sempre continuar o boot via rede (quando disponível)"
			SetDetailsPrint both
			DetailPrint "     Boot de PCs Conhecidos: Sempre continuar o boot via rede (quando disponível)"	
			SetDetailsPrint none
			${DisableX64FSRedirection}
			nsExec::Exec "WDSUTIL /Set-Server /pxepromptpolicy /known:NoPrompt"
			SectionEnd
			
			Section /o "Conectar-se automaticamente (cancelar ao pressionar ESC)"
			SetDetailsPrint both
			DetailPrint "     Boot de PCs conhecidos: conectar-se automaticamente (cancelar ao pressionar ESC)"	
			SetDetailsPrint none
			${DisableX64FSRedirection}
			nsExec::Exec "WDSUTIL /Set-Server /pxepromptpolicy /known:OptOut"
			SectionEnd
			
		SectionGroupEnd
		
		
		SectionGroup "Clientes desconhecidos (Selecione apenas uma)"
			
			Section /o "Necessário apertar F12 para dar boot via rede"
			SetDetailsPrint both
			DetailPrint "     Boot de Novos PCs: Necessário apertar F12 para dar boot via rede"	
			SetDetailsPrint none
			${DisableX64FSRedirection}
			nsExec::Exec "WDSUTIL /Set-Server /pxepromptpolicy /new:OptIn"
			SectionEnd
			
			Section "Sempre continuar o boot via rede (quando disponível)"
			SetDetailsPrint both
			DetailPrint "     Boot de Novos PCs: Sempre continuar o boot via rede (quando disponível)"	
			SetDetailsPrint none
			${DisableX64FSRedirection}
			nsExec::Exec "WDSUTIL /Set-Server /pxepromptpolicy /new:NoPrompt"
			SectionEnd
			
			Section /o "Conectar-se automaticamente (cancelar ao pressionar ESC)"
			SetDetailsPrint both
			DetailPrint "     Boot de Novos PCs: Conectar-se automaticamente (cancelar ao pressionar ESC)"	
			SetDetailsPrint none
			${DisableX64FSRedirection}
			nsExec::Exec "WDSUTIL /Set-Server /pxepromptpolicy /new:OptOut"
			SectionEnd
			
		SectionGroupEnd
		
	SectionGroupEnd
	
SectionGroupEnd
	
	
SectionGroup "Syslinux 4.05 (Necessário WDS para funcionar)"	
	
	Section "Instalar Syslinux 4.05 no WDS"
	
		SetDetailsPrint both
		DetailPrint ""	
		DetailPrint "•   Instalando SysLinux 4.05"	
		SetDetailsPrint none
		
		; pxeboot.0
		DetailPrint "     pxeboot.0"	
		CopyFiles /SILENT "$INSTDIR\Boot\x86\pxeboot.n12" "$INSTDIR\Boot\x86\pxeboot.0"
		CopyFiles /SILENT "$INSTDIR\Boot\x86\pxeboot.n12" "$INSTDIR\Boot\x64\pxeboot.0"
		
		; pxeboot.0 Windows Server 2003 R2 SP2
		${If} ${FileExists} "$INSTDIR\Boot\x86\pxeboot.n12"
		${Else}
		SetOutPath "$INSTDIR\Boot\x86"
		File "Arquivos\Server 2003\pxeboot.0"
		${EndIf}
		
		${If} ${FileExists} "$INSTDIR\Boot\x64\pxeboot.n12"
		${Else}
		SetOutPath "$INSTDIR\Boot\x86"
		File "Arquivos\Server 2003\pxeboot.0"
		${EndIf}

		; abortpxe.0
		SetDetailsPrint both
		DetailPrint "     abortpxe.0"
		SetDetailsPrint none
		CopyFiles /SILENT "$INSTDIR\Boot\x86\abortpxe.com" "$INSTDIR\Boot\x86\abortpxe.0"
		CopyFiles /SILENT "$INSTDIR\Boot\x86\abortpxe.com" "$INSTDIR\Boot\x64\abortpxe.0"
		
		; pxelinux.0
		SetDetailsPrint both
		DetailPrint "     pxelinux.0"
		DetailPrint "     pxelinux.com"
		SetDetailsPrint none
		
		SetOutPath "$INSTDIR\Boot\x86"
		File "Arquivos\Syslinux 4.05\core\pxelinux.0"
		CopyFiles /SILENT "$INSTDIR\Boot\x86\pxelinux.0" "$INSTDIR\Boot\x86\pxelinux.com"
		
		SetOutPath "$INSTDIR\Boot\x64"
		File "Arquivos\Syslinux 4.05\core\pxelinux.0"
		CopyFiles /SILENT "$INSTDIR\Boot\x64\pxelinux.0" "$INSTDIR\Boot\x64\pxelinux.com"
		
		; vesamenu.c32	
		SetDetailsPrint both
		DetailPrint "     vesamenu.c32"
		SetDetailsPrint none	
		SetOutPath "$INSTDIR\Boot\x86"
		File  "Arquivos\Syslinux 4.05\com32\menu\vesamenu.c32"
		SetOutPath "$INSTDIR\Boot\x64"
		File  "Arquivos\Syslinux 4.05\com32\menu\vesamenu.c32"
		
		; chain.c32
		SetDetailsPrint both
		DetailPrint "     chain.c32"
		SetDetailsPrint none
		SetOutPath "$INSTDIR\Boot\x86"
		File "Arquivos\Syslinux 4.05\com32\modules\chain.c32"
		SetOutPath "$INSTDIR\Boot\x64"
		File "Arquivos\Syslinux 4.05\com32\modules\chain.c32"
		
		; default
		SetDetailsPrint both
		DetailPrint "     default"
		SetDetailsPrint none
		SetOutPath "$INSTDIR\Boot\x86\pxelinux.cfg"
		File "Arquivos\Instalacao\default"
		SetOutPath "$INSTDIR\Boot\x64\pxelinux.cfg"
		File "Arquivos\Instalacao\default"
		
		; graphics.conf
		SetDetailsPrint both
		DetailPrint "     graphics.conf"
		SetDetailsPrint none
		SetOutPath "$INSTDIR\Boot\x86\pxelinux.cfg"
		File "Arquivos\Instalacao\graphics.conf"
		SetOutPath "$INSTDIR\Boot\x64\pxelinux.cfg"
		File "Arquivos\Instalacao\graphics.conf"

		; memdisk 
		SetDetailsPrint both
		DetailPrint "     memdisk"
		SetDetailsPrint none
		SetOutPath "$INSTDIR\Boot\x86"
		File "Arquivos\Instalacao\memdisk"
		SetOutPath "$INSTDIR\Boot\x64"
		File "Arquivos\Instalacao\memdisk"

		; Background
		SetDetailsPrint both
		DetailPrint "     background.png"
		SetDetailsPrint none
		SetOutPath "$INSTDIR\Boot\x86"
		File "Arquivos\Instalacao\background.png"
		SetOutPath "$INSTDIR\Boot\x64"
		File "Arquivos\Instalacao\background.png"
		
		; Iso de Exemplo
		SetDetailsPrint both
		DetailPrint "     ISO de Exemplo"
		SetDetailsPrint none
		SetOutPath "$INSTDIR\Boot\x86\Arquivos_e_ISOS\ISOS"
		File "Arquivos\Instalacao\ISOS\iso_exemplo.iso"
		SetOutPath "$INSTDIR\Boot\x64\Arquivos_e_ISOS\ISOS"
		File "Arquivos\Instalacao\ISOS\iso_exemplo.iso"
	
	
	
		; Registrar arquivos de BOOT
		SetDetailsPrint both
		DetailPrint ""	
		DetailPrint "•   Registrando arquivos de boot"	
		SetDetailsPrint none
		
		; bootprogram COMANDO
		SetDetailsPrint both
		DetailPrint "     bootprogram"
		SetDetailsPrint none
		${DisableX64FSRedirection}
		nsExec::Exec "wdsutil /set-server /bootprogram:boot\x86\pxelinux.com /architecture:x86"
		nsExec::Exec "wdsutil /set-server /bootprogram:boot\x64\pxelinux.com /architecture:x64"
		
		; N12bootprogram COMANDO
		SetDetailsPrint both
		DetailPrint "     N12bootprogram"
		SetDetailsPrint none
		${DisableX64FSRedirection}
		nsExec::Exec "wdsutil /set-server /N12bootprogram:boot\x86\pxelinux.com /architecture:x86"
		nsExec::Exec "wdsutil /set-server /N12bootprogram:boot\x64\pxelinux.com /architecture:x64"

	SectionEnd
	
	SectionGroup "Adicionar ao Menu do Syslinux"
	
		Section "-Mensagem"
			SetDetailsPrint both
			DetailPrint ""	
			DetailPrint "•   Instalando programas no Syslinux"	
			SetDetailsPrint none
		SectionEnd
		
		Section "Memtest 4.20"
			SetDetailsPrint both
			DetailPrint "     Instalando Memtest 4.20"
			SetDetailsPrint none
			SetOutPath "$INSTDIR\Boot\x86\Arquivos_e_ISOS\Ferramentas\Teste_de_Memoria"
			File "Arquivos\Instalacao\Ferramentas\Teste_de_Memoria\memtest"
			SetOutPath "$INSTDIR\Boot\x64\Arquivos_e_ISOS\Ferramentas\Teste_de_Memoria"
			File "Arquivos\Instalacao\Ferramentas\Teste_de_Memoria\memtest"		
		SectionEnd
		
		Section "Hardware Detection Tool 0.5.2"
			SetDetailsPrint both
			DetailPrint "     Instalando Hardware Detection Tool 0.5.2"
			SetDetailsPrint none
			SetOutPath "$INSTDIR\Boot\x86\Arquivos_e_ISOS\ISOS"
			File "Arquivos\Instalacao\ISOS\hdt-0.5.2.iso"
			SetOutPath "$INSTDIR\Boot\x64\Arquivos_e_ISOS\ISOS"
			File "Arquivos\Instalacao\ISOS\hdt-0.5.2.iso"
		SectionEnd
		
		Section "ThinStation 2.2.2i"
			SetDetailsPrint both
			DetailPrint "     Instalando ThinStation 2.2.2i"
			SetDetailsPrint none
			; x86
			SetOutPath "$INSTDIR\Boot\x86\Arquivos_e_ISOS\Sistemas\Thinstation"
			File "Arquivos\Instalacao\Ferramentas\Sistemas\Thinstation\initrd"
			File "Arquivos\Instalacao\Ferramentas\Sistemas\Thinstation\vmlinuz"
			; x64
			SetOutPath "$INSTDIR\Boot\x64\Arquivos_e_ISOS\Sistemas\Thinstation"
			File "Arquivos\Instalacao\Ferramentas\Sistemas\Thinstation\initrd"
			File "Arquivos\Instalacao\Ferramentas\Sistemas\Thinstation\vmlinuz"
		SectionEnd
		
	SectionGroupEnd
	
	Section "-Fim"
		SetDetailsPrint both
		DetailPrint ""
		DetailPrint "                                                     Instalação Finalizada                                                   "
		DetailPrint ""
		DetailPrint "                                                     SysWDS by rafaelfndev                                                    "
		DetailPrint "                                                   Visite: rafaelfndev.com.br                                                  "
		DetailPrint ""
		SetDetailsPrint none
		
		MessageBox MB_OK|MB_ICONINFORMATION \
		"• Instalação finalizada! a instalação foi feita na seguinte pasta:$\n\
		$INSTDIR$\n\
		$\n\
		• Importante: alguns computadores carregam o sistema da pasta x86 e alguns da pasta x64, você pode adicionar imagens diferentes para ambos, mas caso você queira que os dois sejam iguais, ao alterar o arquivo da pasta x86, altere também os da pasta x64 e vice-versa.$\n\
		$\n• Não pode haver espaços nos nomes dos arquivos e pastas, isso certamente fará com que seu sistema não funcione.$\n\
		$\n\
		• Para modificar o background altere a imagem que esta na pasta:$\n\
		$INSTDIR\Boot\x86\background.png$\n\
		$INSTDIR\Boot\x64\background.png$\n\
		Formato: PNG - Tamanho Máximo: 640x480$\n\
		$\n\
		• Para adicionar mais sistemas ao menu do Syslinux, edite o arquivo abaixo com qualquer editor de texto (ex: bloco de notas)$\n\
		$INSTDIR\Boot\x86\pxelinux.cfg\default$\n\
		$INSTDIR\Boot\x64\pxelinux.cfg\default$\n\
		$\n\
		• Você pode adicionar imagens de Sistema (.WIM) normalmente utilizando o gerenciador do WDS sem influênciar no menu do Syslinux."
		
		MessageBox MB_OK|MB_ICONINFORMATION \
		"Se tudo ocorreu bem, o WDS e o SysLinux já estão instalados, configurados, e pronto para serem usados.$\n$\n\
		Você já pode dar boot com um computador na rede para testar..."
		
	SectionEnd
	
SectionGroupEnd

