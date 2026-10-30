# Console DRAC5 no Apple Silicon

[English (default)](../drac5-apple-silicon-runbook.md) | [Português (Brasil)](drac5-apple-silicon-runbook.md) | [Índice](README.md)

## Caminho confirmado

A conversa de 12 de setembro confirma VNC e correção de teclado com **JNLP recente baixado manualmente e viewer Java x86 de 32 bits**. O fetcher Playwright somente com credenciais foi proposto; não há teste posterior nem ZIP original disponível. O bundle atual implementa o caminho manual, sem declarar login automático validado.

O JAR `avctKVMIOLinux.jar` contém JNI `libavctKVMIO.so` ELF32 Intel 80386. JVM ARM64 ou amd64 não carrega essa biblioteca; é necessário userspace/JVM i386 e suporte de emulação linux/386 no Docker.

## Reproduzir

1. Acesse o DRAC5 pela rede OOB privada e faça login normalmente.
2. Abra **Console → Console Redirect → Connect** e baixe `vkvm.jnlp` recente. Mantenha sessão conforme firmware.
3. Inspecione privadamente: classe observada `com.avocent.drac5.kvm.Main`; argumento `user` pode ser token temporário, sem correspondência com login da conta.
4. Obtenha da mesma sessão `plugins/vkvm/avctDRAC5Viewer.jar` e `plugins/vkvm/avctKVMIOLinux.jar`; valide arquivos e hashes.
5. Prepare JDK8 i386, biblioteca JNI e dependências. Use os caminhos privados descritos no [guia de automação](automation.md).
6. Inicie X virtual, gerenciador de janelas e x11vnc no ambiente isolado. Publique VNC somente em loopback, com senha própria, diferente da senha do BMC.
7. Inicie o viewer preservando limites dos argumentos JNLP, sem interpolação shell insegura ou tokens nos logs.
8. Abra Screen Sharing em `vnc://127.0.0.1:5900`.
9. No viewer, habilite **Tools → Session Options → General → Pass all keystrokes to target → OK**. Esta foi a correção de teclado confirmada.
10. Teste navegação BIOS, ponteiro, teclas especiais, reboot/reconexão e interações necessárias. Renove JNLP expirado.

```bash
bash scripts/drac5.sh build
bash scripts/drac5.sh vnc
# Ao encerrar:
bash scripts/drac5.sh down
```

Dentro do runtime preparado:

```bash
getconf LONG_BIT
java -version
file /opt/drac5/native/libavctKVMIO.so
ldd /opt/drac5/native/libavctKVMIO.so
```

Espere ELF32/i386, sem bibliotecas obrigatórias ausentes. Se menus recebem teclado mas o console não, investigue captura Avocent e JNI antes de alterar a rede.

## Rede, TLS e automação futura

O JNLP observado usa portas do controlador 5900 para teclado/mouse e 5901 para vídeo. VNC local 5900 é outro salto: teste resolução e alcance do BMC dentro do container. Não publique BMC ou viewer na internet.

O login DRAC5 observado usa `/cgi-bin/webcgi/login` e cookie `sid`; `/rpc/WEBSES/create.asp` retornou 404. XML/XSL e frames impedem assumir scraping HTML simples. Flags TLS dependem do backend curl. Exceções legadas, se inevitáveis, devem ficar restritas ao runtime descartável e controlador escolhido, sem enfraquecer a estação globalmente.

Automatize o download somente após o caminho manual funcionar; proteja cookies/JNLP, não exponha screenshots/logs sensíveis e mantenha renovação manual como fallback. Ao terminar, pare o container e remova sessões expiradas; o volume de preferências é mantido. Valide mídia virtual separadamente: seu sucesso não foi demonstrado na conversa. Consulte o [original](../drac5-apple-silicon-runbook.md) para o histórico completo.
