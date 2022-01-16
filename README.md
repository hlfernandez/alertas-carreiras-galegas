# Alertas de Carreiras en Galicia

Este repositorio contén o código fonte que emprego para procesar a información sobre as carreiras que se desenvolven en Galicia e publicala automaticamente [nesta canle de Telegram](https://t.me/carreiras_galicia). Actualmente recolectase a información de dúas fontes: [Champion Chip Norte](championchipnorte.com/) e [Carreiras Galegas](https://www.carreirasgalegas.com/calendario).

Os scripts `process_carreiras_galegas.sh` e `process_ccnorte.sh` baixan toda a información sobre carreiras dispoñible nas dúas páxinas e gardan a información en dous ficheiros que se crean na carpeta `data`. No momento en que se garda a información dunha carreira compróbase se esta xa estaba na base de datos, e se non o estaba entón publícase na canle de Telegram.

A publicación na canle de Telegram faise cun bot e os scripts cargan esta configuración dun ficheiro `bot.conf` que debe existir no mesmo directorio no que están os scripts. Este ficheiro debe conter o seguinte:

```
BOT_ID_TOKEN=<bot_id_token>
CHAT_ID=<chat_id>
```
