![SysWDS intro](https://github.com/rafaelfndev/SysWDS/blob/main/_FILES/Imagens/top.bmp)

# Aviso importante
Esse é um projeto que desenvolvi há muitos anos (completou 10 anos agora em 2023). Infelizmente **não** estarei implementando nenhuma outra funcionalidade ou realizando correções, e também **não** tenho como oferecer nenhum tipo de suporte daqui em diante.

Todo o código fonte e os arquivos que utilizei estão nesse repositório, fique a vontade para modifica-los como quiser.

O domínio rflfn[.]com não me pertence mais há muitos anos, então por favor, não cliquem nesses links. Para prevenir maiores riscos, compilei uma versão atual apenas com links atualizados para meu domínio, essa versão não tem nada de diferente, apenas as correções destes links.

# Use por sua conta e risco
Este Software é livre, e desenvolvido com outros Softwares livres! Não me responsabilizo por qualquer dano ou configuração incorreta que você venha a fazer, ou a forma que vai utilizá-lo. Ao utilizar esse software, você assume total risco sobre seu uso.

# SysWDS: Para que serve?
**SysWDS** é uma junção do [Syslinux](https://wiki.syslinux.org/wiki/index.php?title=The_Syslinux_Project) + [WDS (Windows Deployment Services)](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012). Esse utilitário instala o Syslinux no WDS de forma automatizada e já configura ambos os serviços.

Após a instalação, você consegue dar boot em um computador na rede através do PXE-LAN (sem sistema operacional), e se conectar ao servidor Windows. Após se conectar, é exibido um prompt com algumas opções disponíveis do servidor, como teste de memória, testes de hardware, ThinStation, e diversas outras ferramentas que você pode a adicionar ao menu do Syslinux. Com ele também é possível instalar o Windows através da rede.

# Download SysWDS
Faça o [download do SysWDS aqui](https://github.com/rafaelfndev/SysWDS/releases).

# Instalação
Parece complexo? Mas é bem simples, assista ao vídeo mais abaixo para entender como funciona.

**Aviso importante sobre o vídeo:** o vídeo está disponível em conta antiga minha do YouTube, e infelizmente eu não tenho mais acesso a ela, então por favor, não cliquem nos links rflfn[.]com, esse domínio não me pertence mais.

https://www.youtube.com/watch?v=dtZSFEEt-kk

# Versões Suportadas (32 Bits e 64 Bits):
- Windows Server 2003 R2 com Service Pack 2
- Windows Server 2008
- Windows Server 2008 R2
- Windows Server 2012

# Pré requisitos:
Ter previamente instalado Servidor DHCP e o AD (Active Directory), assim logo após o termino da instalação o serviço WDS já estará instalado e funcionando com o Syslinux configurado.

Antes de instalar no Windows Server 2003 R2 SP2 insira o CD de instalação do Windows, nesta versão, diferentemente das outras versões do Windows Server, ele adiciona funções utilizando os 'recursos do Windows', e estes recursos adicionais são instalados através do CD de instalação. Apesar de necessitar do CD de instalação, todo processo é automático, mas caso não seja inserido o CD de instalação, provavelmente será exibido algumas mensagens de erro e certamente a instalação irá falhar.

Não instale o WDS em uma pasta com espaços no nome ou a instalação irá falhar. Não adicione pasta com espaços no nome que não ira funcionar.

# Recomendações:
Caso o serviço WDS ja esteja instalado, recomendo remover antes de instalar este programa ou indicar a pasta onde esta instalado o WDS (Não contendo nenhuma modificação).

# Importante:
Este software não faz alterações no registro ou cria arquivos 'desnecessários' em qualquer outra pasta que não seja a pasta da instalação, para removê-lo basta apagar os arquivos localizados na pasta onde o mesmo se encontra instalado, caso ocorra algum problema com o WDS, reinstale o serviço para remover qualquer configuração que este software tenha feito.

# Compilar projeto:
Você pode criar seu próprio build, é simples:

1. Instale o [NSIS (Nullsoft Scriptable Install System)](https://sourceforge.net/projects/nsis/).
2. Execute o NSIS, e abra o arquivo **_Instalador.nsi**
3. Pronto =]

# Licença
MIT
