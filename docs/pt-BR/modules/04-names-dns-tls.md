# 04 · Names — DNS e TLS

[English (default)](../../../modules/04-names-dns-tls.md) | [Português (Brasil)](04-names-dns-tls.md) | [Índice](../README.md)

A fase `names` configura DNS independente; `gatehouse` prepara DNS-01 e Gateway HTTPS. Veja [automação](../automation.md).

## Procedimento

1. Escolha nomes canônicos sob `den.int.example.net`. DNS interno aponta apps ao Gateway `172.16.3.200` e API ao seu VIP distinto.
2. Confirme respostas pela LAN e VPNs. DNS dividido deve manter origem canônica da aplicação, mesmo com caminho externo diferente.
3. Antes de migrar autoridade, inventarie MX/TXT/DKIM/DMARC/CAA, validações, aliases, delegações e DNSSEC/DS; preserve exportação e retorno. Cloudflare no site não significa autoridade DNS migrada.
4. Instale cert-manager fixado e compatível, começando com ACME staging e credencial de zona restrita.
5. Cloudflare usa token DNS Edit/Zone Read restrito à zona; Route 53 usa IAM limitado à hosted zone e operações necessárias.
6. Se `_acme-challenge` usa CNAME, configure seguimento e permissão na zona final. Confira resolução autoritativa/pública.
7. Valide certificado descartável, Orders/Challenges e propagação antes de produção.
8. Emita wildcard do domínio real no namespace do Gateway e referencie Secret no listener HTTPS.
9. Teste validação normal de hostname/cadeia; `curl -k` não é aprovação.

```bash
dig @172.16.5.53 backstage.den.int.example.net A
kubectl get clusterissuer
kubectl -n gateway-system get certificate
kubectl get orders,challenges -A
curl --resolve backstage.den.int.example.net:443:172.16.3.200 \
  https://backstage.den.int.example.net/
```

Os comandos usam endereços de exemplo; substitua pelo contrato real. Split DNS pode ocultar challenges no self-check; diagnostique autoridade e resolvers. DNS-01 não exige abrir porta 80 WAN.

## Escopo dos certificados e registros

`*.den.int.example.net` não cobre nomes mais profundos de API/OOB. PKI kubeadm, certificado de origem do Gateway e TLS da borda Cloudflare são separados. Verifique cobertura real da borda, SNI, callback e base URL. Certificados públicos podem expor nomes em transparência de certificados.

ExternalDNS ainda é planejado no histórico: mantenha registros manuais até adoção deliberada. Para RFC2136, restrinja TSIG/zona, use TXT owner distinto, dry-run e política inicial não destrutiva. Remova dupla responsabilidade antes de sync, que pode apagar registros sob seu controle.
