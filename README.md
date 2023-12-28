# Alertas de Carreiras en Galicia

Este repositorio contén o código fonte que emprego para procesar a información sobre as carreiras que se desenvolven en Galicia e publicala automaticamente [nesta canle de Telegram](https://t.me/carreiras_galicia). 

Actualmente recompílase a información de cinco fontes:
- [Champion Chip Norte](championchipnorte.com/).
- [Carreiras Galegas](https://www.carreirasgalegas.com/calendario).
- [Sportmaniacs](https://sportmaniacs.com/).
- [MagmaSports](https://magmasports.es/).
- [forestrun](https://forestrun.es/).

Os scripts `process_*.sh` baixan toda a información sobre carreiras dispoñible nas dúas páxinas e gardan a información en ficheiros que se crean na carpeta `data` (un por fonte). No momento en que se garda a información dunha carreira compróbase se esta xa estaba na base de datos, e se non o estaba entón publícase na canle de Telegram.

A publicación na canle de Telegram faise cun bot e os scripts cargan esta configuración dun ficheiro `bot.conf` que debe existir no mesmo directorio no que están os scripts. Este ficheiro debe conter o seguinte:

```A
BOT_ID_TOKEN=<bot_id_token>
CHAT_ID=<chat_id>
```

## Resumos mensuais

Os scripts `publish_*_mes.sh` permiten publicar unha mensaxe cun resumo das carreiras do mes indicado. Os scripts crean os ficheiros cas carreiras filtradas créanse en `data/<mes>`. Por exemplo, `publish_ccnorte_mes.sh febreiro` publicará unha mensaxe cas carreiras do mes de febreiro publicadas en Champion Chip Norte. 

## Cambios

- En decembro de 2023 volven a funcionar os scripts para [forestrun](https://forestrun.es/), co novo parser implementado xa en Python.
- En xullo de 2023 mígrase o proceso de DeporTicket, MagmaSports e Carreiras Galegas a código Python.
- Desde xaneiro de 2023 deixan de funcionar os scripts para [forestrun](https://forestrun.es/). Cambiou o formato da páxina.
