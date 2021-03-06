Harbour Shell / Script Runner 3.4.0dev \(c390da90ad\) \(2017-10-10 16:11\)  
Copyright &copy; 2007-present, Viktor Szakats  
Copyright &copy; 2003-2007, Przemysław Czerpak  
<https://github.com/vszakats/hb/>  
Tradução \(pt\_BR\): Sami Laham &lt;sami@laham.com.br&gt; / Vailton Renato &lt;vailtom@gmail.com&gt;  

Sintaxe:  
  
  hbrun &lt;file\[.hb|.prg|.hrb|.dbf\]|-dbf:file|-prg:string&gt;|&lt;option&gt; \[&lt;parâmetro\[s\]&gt;\]  
  
Descrição:  


  hbrun está habilitado a rodar scripts Harbour \(ambos fonte e pré-compilado\), e dispõe também de um "prompt shell" interativo.
  
Opções abaixo estão disponíveis em linha de comando:  


 - **--hb:debug** ativar debugação de script


 - **-help** esta ajuda
 - **-viewhelp** full help in text viewer
 - **-fullhelp** full help
 - **-fullhelpmd** full help in [Markdown](https://daringfireball.net/projects/markdown/) format
 - **-version** exibir somente o cabeçalho com a versão do hbmk
  
Arquivos:  


 - **\*.hb** script Harbour
 - **\*.hrb** Harbour binario portável \(Também conhecido como Harbour script pré-compilado\)
 - **hbstart.hb** arquivo de inicialização de script para shell interativo Harbour. Se presente ele é executado automaticamente na inicialização do shell. Localizações possíveis \(em ordem de precedência\) \[\*\]: ./, $HOME/.harbour, /etc/harbour, etc/harbour, etc, &lt;hbrun diretório&gt;
 - **shell plugins** .hb e .hrb plugins para shell interativo Harbour. Eles pode residir em \[\*\]: $HOME/.harbour/
 - **.hb\_history** armazena o histórico de comando do shell interativo Harbour shell. Voce pode desabilitar o histórico fazendo a primeira linha 'no' \(sem aspas e com nova linha\). Localizado em \[\*\]: $HOME/.harbour/
 - **hb\_extension** lista de extensões a ser carregada no shell interativo Harbour. Uma extensão por linha, a parte alem do caracter '\#' será ignorada. Nome alternativo em MS-DOS: hb\_ext.ini. localizado em \[\*\]: $HOME/.harbour/


Constantes pré-definidas nos fontes \(não defini-las manualmente\):


 - **\_\_HBSCRIPT\_\_HBSHELL** quando um programa fonte Harbour está rodando como "shell script"
 - **&lt;standard Harbour&gt;** \_\_PLATFORM\_\_\*, \_\_ARCH\*BIT\_\_, \_\_\*\_ENDIAN\_\_, etc.
  
Variáveis ​​de ambiente:  


 - **HB\_EXTENSION** lista de extensões para carga no shell interativo do Harbour separada por espaço
  
Shell API disponível nos scripts em Harbour:  


 - **hbshell\_gtSelect\( \[&lt;cGT&gt;\] \) -&gt; NIL**  
Mudar GT. Padrão \[\*\]: 'gttrm'
 - **hbshell\_Clipper\(\) -&gt; NIL**  
Enable Cl\*pper compatibility \(non-Unicode\) mode.
 - **hbshell\_include\( &lt;cHeader&gt; \) -&gt; &lt;lSuccess&gt;**  
Carregar cabeçalho "header" Harbour.
 - **hbshell\_uninclude\( &lt;cHeader&gt; \) -&gt; &lt;lSuccess&gt;**  
Descarregar cabeçalho "header" Harbour.
 - **hbshell\_include\_list\(\) -&gt; NIL**  
Mostra a lista de cabeçalhos Harbour carregados.
 - **hbshell\_ext\_load\( &lt;cPackageName&gt; \) -&gt; &lt;lSuccess&gt;**  
carregar pacote. Similar para diretivas de \#request PP.
 - **hbshell\_ext\_unload\( &lt;cPackageName&gt; \) -&gt; &lt;lSuccess&gt;**  
Descarregar pacote.
 - **hbshell\_ext\_get\_list\(\) -&gt; &lt;aPackages&gt;**  
Lista de pacotes carregados.
 - **hbshell\_DirBase\(\) -&gt; &lt;cBaseDir&gt;**  
hb\_DirBase\(\) não mapeado para script.
 - **hbshell\_ProgName\(\) -&gt; &lt;cPath&gt;**  
hb\_ProgName\(\) não mapeado para script.
 - **hbshell\_ScriptName\(\) -&gt; &lt;cPath&gt;**  
Nome do script em execução.
  
Notas:  


  - .hb, .prg, .hrb ou .dbf file passed as first parameter will be run as Harbour script. If the filename contains no path components, it will be searched in current working directory and in PATH. If not extension is given, .hb and .hrb extensions are searched, in that order. .dbf file will be opened automatically in shared mode and interactive Harbour shell launched. .dbf files with non-standard extension can be opened by prepending '-dbf:' to the file name. Otherwise, non-standard extensions will be auto-detected for source and precompiled script types. Note, for Harbour scripts, the codepage is set to UTF-8 by default. The default core header 'hb.ch' is automatically \#included at the interactive shell prompt. The default date format is the ISO standard: yyyy-mm-dd. SET EXACT is set to ON. Set\( \_SET\_EOL \) is set to OFF. The default GT is 'gtcgi', unless full-screen CUI calls are detected, when 'gttrm' \[\*\] is automatically selected \(except for INIT PROCEDUREs\).
  - You can use key &lt;Ctrl\+V&gt; in interactive Harbour shell to paste text from the clipboard.
  - Valores marcados com \[\*\] pode ser plataforma hospedagem e/ou configuração dependente. Esta ajuda foi gerada em 'darwin' plataforma de hospedagem.
  
Licença:  


  This program is free software; you can redistribute it and/or modify  
it under the terms of the GNU General Public License as published by  
the Free Software Foundation; either version 2 of the License, or  
\(at your option\) any later version.  
  
This program is distributed in the hope that it will be useful,  
but WITHOUT ANY WARRANTY; without even the implied warranty of  
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  
GNU General Public License for more details.  
  
You should have received a copy of the GNU General Public License  
along with this program; if not, write to the Free Software Foundation,  
Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.  
\(or visit their website at https://www.gnu.org/licenses/\).  
  
License extensions:  
  - This source code must be kept and distributed as part  
    of the Harbour package and/or the placement of the tool sources  
    and files must reflect that it is part of Harbour Project.  
  - Copyright information must always be presented by  
    projects including this tool or help text.  
  - Modified versions of the tool must clearly state this  
    fact on the copyright screen.  
  - Source code modifications shall always be made available  
    along with binaries.  
  - Help text and documentation is licensed under  
    Creative Commons Attribution-ShareAlike 4.0 International:  
    https://creativecommons.org/licenses/by-sa/4.0/  

  
Autor:  


 - Viktor Szakats 
