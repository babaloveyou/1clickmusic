unit radios;

interface

const //# genre index
  ELETRONIC = 0;
  DOWNTEMPO = 1;
  ROCKMETAL = 2;
  ECLETIC = 3;
  HIPHOP = 4;
  OLDMUSIC = 5;
  INDUSTRIAL = 6;
  MISC = 7;
  BRASIL = 8;

const
  genrelist: array[0..8] of string = (
    'Eletronic',
    'Downtempo',
    'Rock / Metal',
    'Ecletic',
    'Hip-Hop',
    '80''s / 90''s / Classic',
    'Industrial',
    'Others',
    'Brasileiras'
    );

const
  chn_eletronic: array[0..62] of string = (
    'Hardstyle ( hard.fm )',
    'Hardstyle ( hardbase )',
    'House Eletro ( housetime )',
    'House SoulFull ( freshhouse )',
    'Trance ( afterhours )',
    'Club ( blitz )',
    'Club ( playdio )',
    'Club ( xtcradio )',
    'Club ( techno4ever )',
    'Club ( pulsradio )',
    'Club ( technobase )',
    'Club ( frenchkiss )',
    'Club ( radioseven )',
    'Club ( rautemusik )',
    'Club ( 1.fm )',
    'Dance ( 1.fm )',
    'Trance ( 1.fm )',
    'House Funky ( rautemusik )',
    'Progressive ( soma )',
    'Psy ( philosomatika )',
    'Psy ( psyradio )',
    'Psy Prog ( psyradio )',
    'Trance ( neradio )',
    'Drum''and''Bass ( dnbradio )',
    'Drum''and''Bass ( bassdrive)',
    'House Eletro ( DI )',
    'House Tribal ( DI )',
    'House Funky ( DI )',
    'Hardstyle ( DI )',
    'Trance ( DI )',
    'Trance Vocal ( DI )',
    'Eurodance ( DI )',
    'House ( DI )',
    'House SoulFull ( DI )',
    'Harddance ( DI )',
    'Techno ( DI )',
    'Progressive ( DI )',
    'Psy ( DI )',
    'Hardcore ( DI )',
    'DJ-Mixes ( DI )',
    'Drum''and''Bass ( DI )',
    'Techno Classic ( DI )',
    'BreakBeat ( DI )',
    'Futurepop ( DI )',
    'Gabber ( DI )',
    'Jumpstyle ( imusicfm )',
    'Jumpstyle ( fear )',
    'Hardstyle ( fear )',
    'BreakBeat ( 1.breaksfm )',
    'BreakBeat ( 2.breaksfm )',
    'Dance ( 181.fm )',
    'Eurodance ( 181.fm )',
    'Psy Mixes ( psychedelik )',
    'Psy ( psychedelik )',
    'Psy Prog ( psychedelik )',
    'Psy Dark ( psychedelik )',
    'Psy Dark ( triplag )',
    'Psy DarkAmbient ( triplag )',
    'Dance ( frisky )',
    'Alternative ( RaveTrax )',
    'Alternative ( 1.fm )',
    'Dance ( FG Radio )',
    'Dance ( ibizaglobal )'
    );

const
  pls_eletronic: array[0..62] of string = (
    'http://files.hard.fm/128.pls',
    'http://mp3.hardbase.fm/listen.pls',
    'http://high.housetime.fm/listen.pls',
    'http://85.21.79.5:8040/listen.pls',
    'http://stats.ah.fm/dynamicplaylist.m3u?quality=96',
    'http://blitz-stream.de/stream/stream.m3u',
    'http://www.playdio.se/bredband.pls',
    'http://stream.xtcradio.com:8069/listen.pls',
    'http://listen.to.techno4ever.net/dsl/mp3',
    'http://www.pulsradio.com/pls/puls-adsl.m3u',
    'http://dsl.technobase.eu/listen-dsl.pls',
    'http://88.191.35.197/listen.pls',
    'http://www.radioseven.se/128.pls',
    'http://club-office.rautemusik.de/listen.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=6057&file=filename.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=6201&file=filename.pls',
    'http://www.1.fm/trance.pls',
    'http://funky-office.rautemusik.de/listen.pls',
    'http://somafm.com/tagstrance.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=1712&file=filename.pls',
    'http://streamer.psyradio.org:8030/listen.pls',
    'http://streamer.psyradio.org:8010/listen.pls',
    'http://www.neradio.se/listen.pls',
    'http://www.dnbradio.com/hi.pls',
    'http://www.bassdrive.com/v2/streams/BassDrive.pls',
    'http://www.di.fm/mp3/electro.pls',
    'http://www.di.fm/mp3/tribalhouse.pls',
    'http://www.di.fm/mp3/funkyhouse.pls',
    'http://www.di.fm/mp3/hardstyle.pls',
    'http://www.di.fm/mp3/trance.pls',
    'http://www.di.fm/mp3/vocaltrance.pls',
    'http://www.di.fm/mp3/eurodance.pls',
    'http://www.di.fm/mp3/house.pls',
    'http://www.di.fm/mp3/soulfulhouse.pls',
    'http://www.di.fm/mp3/harddance.pls',
    'http://www.di.fm/mp3/techno.pls',
    'http://www.di.fm/mp3/progressive.pls',
    'http://www.di.fm/mp3/goapsy.pls',
    'http://www.di.fm/mp3/hardcore.pls',
    'http://www.di.fm/mp3/djmixes.pls',
    'http://www.di.fm/mp3/drumandbass.pls',
    'http://www.di.fm/mp3/classictechno.pls',
    'http://www.di.fm/mp3/breaks.pls',
    'http://www.di.fm/mp3/futuresynthpop.pls',
    'http://www.di.fm/mp3/gabber.pls',
    'http://www.imusicfm.nl/listen.pls',
    'http://internetradio.fearfm.nl/customplayer/fearfm_hard_high.pls',
    'http://internetradio.fearfm.nl/customplayer/fearfm_harder_high.pls',
    'http://stream.breaksfm.com:9000/listen.pls',
    'http://stream002.breaksfm.com:9000/listen.pls',
    'http://www.181.fm/winamp.pls?station=181-energy98&bitrate=hi',
    'http://www.181.fm/winamp.pls?station=181-energy93&bitrate=hi',
    'http://88.191.15.43:8020/listen.pls',
    'http://88.191.38.140:8000/listen.pls',
    'http://88.191.38.140:8010/listen.pls',
    'http://88.191.38.140:8014/listen.pls',
    'http://www.triplag.com/webradio/darkpsy/triplag-darkpsy.php',
    'http://www.triplag.com/webradio/chilltrip/triplag-chilltrip.php',
    'http://friskyradio.com/frisky.m3u',
    'http://ravetrax.com/mp3_hi.pls',
    'http://www.1.fm/electronica.pls',
    'http://fg.impek.tv/listen.pls',
    'http://s6.viastreaming.net:7010/listen.pls'
    );


const
  chn_downtempo: array[0..21] of string = (
    'Minimal ( deepmix )',
    'Chillout ( 1.fm )',
    'Lounge ( rautemusik )',
    'Lounge ( smoothlounge )',
    'Ambient Mysterious ( soma )',
    'Ambient IDM ( soma )',
    'Chillout ( soma )',
    'Ambient Industrial ( soma )',
    'Ambient Space ( soma )',
    'Ambient Drone ( soma )',
    'Ambient House ( soma )',
    'Chillout ( psyradio )',
    'Minimal ( psyradio )',
    'New Age ( DI )',
    'Minimal ( DI )',
    'Chillout ( DI )',
    'Lounge ( DI )',
    'Lounge Datempo ( sky )',
    'Ambient ( DI )',
    'Chillout ( bluefm )',
    'Chillout ( 181.fm )',
    'Chillout ( psychedelik )'
    );

const
  pls_downtempo: array[0..21] of string = (
    'http://85.21.79.5:8040/listen.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=6951&file=filename.pls',
    'http://lounge-office.rautemusik.de/listen.pls',
    'http://www.smoothlounge.com/streams/smoothlounge_128.pls',
    'http://somafm.com/secretagent.pls',
    'http://somafm.com/cliqhop.pls',
    'http://somafm.com/groovesalad.pls',
    'http://somafm.com/doomed.pls',
    'http://somafm.com/spacestation.pls',
    'http://somafm.com/dronezone.pls',
    'http://somafm.com/beatblender.pls',
    'http://streamer.psyradio.org:8020/listen.pls',
    'http://streamer.psyradio.org:8040/listen.pls',
    'http://www.sky.fm/mp3/newage.pls',
    'http://www.di.fm/mp3/minimal.pls',
    'http://www.di.fm/mp3/chillout.pls',
    'http://www.di.fm/mp3/lounge.pls',
    'http://www.sky.fm/mp3/datempolounge.pls',
    'http://www.di.fm/mp3/ambient.pls',
    'http://bluefm.net/listen.pls',
    'http://www.181.fm/winamp.pls?station=181-chilled&bitrate=hi',
    'http://88.191.38.140:8014/listen.pls'
    );

const
  chn_rockmetal: array[0..23] of string = (
    'Indie Rock ( soma )',
    'Punk Rock ( hifipunk )',
    'Punk Rock ( idobi )',
    'Classic Rock ( 977music )',
    'Alternative ( 977music )',
    'Rock/Metal ( 977music )',
    'Rock/Metal ( edge )',
    'Rock/Metal ( 525 )',
    'Rock/Metal ( cxraggression )',
    'Rock/Metal ( cxrmetal )',
    'Rock/Metal ( cxrgrit )',
    'Classic Rock ( sky )',
    'Indie Rock ( sky )',
    'Alternative ( sky )',
    'Alternative ( 181.fm )',
    'Classic Rock ( 181. fm)',
    'Rock/Metal ( rautemusik )',
    'Rock/Metal ( channel x.1.fm )',
    'Rock/Metal ( high voltage.1.fm )',
    'Rock/Metal ( metalonly )',
    'Rock/Metal ( kinkfm )',
    'Rock/Metal ( gothmetal )',
    'Rock/Metal ( rocky )',
    'Classic Rock ( rock&rollfm )'
    );

const
  pls_rockmetal: array[0..23] of string = (
    'http://somafm.com/indiepop.pls',
    'http://128.hifipunk.com:8000/listen.pls',
    'http://www.idobi.com/radio/iradio.pls',
    'http://www.977music.com/tunein/web/classicrock.asx',
    'http://www.977music.com/tunein/web/mix.asx',
    'http://www.977music.com/tunein/web/rock.asx',
    'http://edge-radio.net/edgeradio/edge.m3u',
    'http://64.62.252.134:6670/listen.pls',
    'http://www.chronixradio.com/chronixaggression/listen/listen.pls',
    'http://www.chronixradio.com/cxrmetal/listen/listen.pls',
    'http://www.chronixradio.com/cxrgrit/listen/listen.pls',
    'http://www.sky.fm/mp3/classicrock.pls',
    'http://www.sky.fm/mp3/indierock.pls',
    'http://www.sky.fm/mp3/altrock.pls',
    'http://www.181.fm/winamp.pls?station=181-buzz&bitrate=hi',
    'http://www.181.fm/winamp.pls?station=181-eagle&bitrate=hi',
    'http://extreme-office.rautemusik.de/listen.pls',
    'http://www.1.fm/x.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=9592&file=filename.pls',
    'http://metal-only.de/listen.pls',
    'http://www.kinkfm.com/streams/kink_aardschok.m3u',
    'http://82.134.68.36:7999/listen.pls',
    'http://www.rockyfm.de/listen.pls',
    'http://tunein.swcast.net/launch.cgi/dade921/hi-band.pls'
    );

const
  chn_ecletic: array[0..12] of string = (
    'Ecletic ( fusionchicago )',
    'Ecletic ( paradise )',
    'Ecletic ( enjoystation )',
    'Ecletic ( sky )',
    'Ecletic ( 1.fm )',
    'Ecletic ( 977music )',
    'Ecletic ( frequence3 )',
    'Ecletic ( power.181.fm )',
    'Ecletic ( mix.181.fm )',
    'Ecletic ( point.181.fm )',
    'Ecletic ( party.181.fm )',
    'Ecletic ( rautemusik )',
    'Ecletic ( HitzRadio )'
    );

const
  pls_ecletic: array[0..12] of string = (
    'http://streams.fusionchicago.com/128.pls',
    'http://www.radioparadise.com/musiclinks/rp_128-1.m3u',
    'http://www.enjoystation.net/player/mp3.m3u',
    'http://www.sky.fm/mp3/tophits.pls',
    'http://www.1.fm/top40.pls',
    'http://www.977music.com/tunein/web/hitz.asx',
    'http://streams.frequence3.fr/mp3-192.m3u',
    'http://www.181.fm/winamp.pls?station=181-power&bitrate=hi',
    'http://www.181.fm/winamp.pls?station=181-themix&bitrate=hi',
    'http://www.181.fm/winamp.pls?station=181-thepoint&bitrate=hi',
    'http://www.181.fm/winamp.pls?station=181-party&bitrate=hi',
    'http://main-office.rautemusik.de/listen.pls',
    'http://www.hitzradio.com/hitzradio.pls'
    );

const
  chn_hiphop: array[0..11] of string = (
    'HipHop ( blackbeats )',
    'HipHop ( powerhitz )',
    'HipHop ( thugzone )',
    'HipHop ( defjay )',
    'HipHop ( rautemusik )',
    'HipHop ( 1.fm )',
    'HipHop ( hot108 )',
    'HipHop ( beat.181.fm )',
    'HipHop ( box.181.fm )',
    'HipHop ( sky )',
    'Classic Rap ( sky )',
    'HipHop ( smoothbeats )'
    );

const
  pls_hiphop: array[0..11] of string = (
    'http://www.blackbeats.fm/listen.m3u',
    'http://www.powerhitz.com/ph.pls',
    'http://www.thugzone.com/broadband-128.pls',
    'http://www.defjay.com/listen.pls',
    'http://jam-office.rautemusik.de/listen.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=5548&file=filename.pls',
    'http://www.hot108.com/hot108.pls',
    'http://www.181.fm/winamp.pls?station=181-beat&bitrate=hi',
    'http://www.181.fm/winamp.pls?station=181-thebox&bitrate=hi',
    'http://www.sky.fm/mp3/urbanjamz.pls',
    'http://www.sky.fm/mp3/classicrap.pls',
    'http://www.smoothbeats.com/listen.pls'
    );

const
  chn_oldmusic: array[0..16] of string = (
    '60''s ( sky )',
    '70''s ( sky )',
    '80''s ( sky )',
    '90''s ( star.181.fm )',
    '60''s - 70''s ( oldies.181.fm )',
    '80''s ( awesome.181.fm )',
    '80''s ( lite.181.fm )',
    '90''s ( 181.fm )',
    '80''s ( 977music )',
    '90''s ( 977music )',
    '50''s - 80''s ( rautemusik )',
    'Oldies ( sky )',
    'Baroque ( 1.fm )',
    'Opera ( 1.fm )',
    'Classical ( 1.fm )',
    '80''s ( asf )',
    '80''s ( chaos )'
    );

const
  pls_oldmusic: array[0..16] of string = (
    'http://www.sky.fm/mp3/oldies.pls',
    'http://www.sky.fm/mp3/hit70s.pls',
    'http://www.sky.fm/mp3/the80s.pls',
    'http://www.181.fm/winamp.pls?station=181-star90s&bitrate=hi',
    'http://www.181.fm/winamp.pls?station=181-greatoldies&bitrate=hi',
    'http://www.181.fm/winamp.pls?station=181-awesome80s&bitrate=hi',
    'http://www.181.fm/winamp.pls?station=181-lite80s&bitrate=hi',
    'http://www.181.fm/winamp.pls?station=181-star90s&bitrate=hi',
    'http://www.977music.com/tunein/web/80s.asx',
    'http://www.977music.com/tunein/web/90s.asx',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=6422&file=filename.pls',
    'http://www.sky.fm/mp3/classical.pls',
    'http://www.1.fm/baroque.pls',
    'http://www.1.fm/opera.pls',
    'http://www.1.fm/classical.pls',
    'http://www.atlanticsoundfactory.com/asfbb.pls',
    'http://www.chaos-radio.net/stream/listen.m3u'
    );

const
  chn_industrial: array[0..9] of string = (
     //'Post Industrial ( darksection )',
     //'Post Industrial ( dunkle )',
    'Post Industrial ( darkness )',
    'Post Industrial ( tormented )',
    'Post Industrial ( digitalgunfire )',
    'Post Industrial ( ultradark )',
    'Post Industrial ( golgotha )',
    'Post Industrial ( schwarze )',
    'Post Industrial ( r1live )',
    'Post Industrial ( rantradio )',
    'Post Industrial ( realindustrial )',
    'Post Industrial ( vampirefreaks )'
    );

const
  pls_industrial: array[0..9] of string = (
     // 'http://dark-section.de/streams/winamp_128.pls',
     // 'http://www.dunklewelle.de/modules/mod_internetradio/makeplaylist.php?ip=87.106.67.16&port=10000&format=M3U',
    'http://radio.darkness.com/listen.pls',
    'http://playlist.tormentedradio.com/radioG.pls',
    'http://www.digitalgunfire.com/playlist.pls',
    'http://www.ultradarkradio.com/listen.pls',
    'http://38.96.148.24:6764/listen.pls',
    'http://www.schwarze-welle.com/play.m3u',
    'http://www.r1live.de/player/winamp.pls',
    'http://www.rantmedia.ca/industrial/rr-industrial128.pls',
    'http://radio.realindustrialradio.com:8000/listen.pls',
    'http://vfradio.com/listen/8000.m3u'
    );

const
  chn_misc: array[0..34] of string = (
    'Folk ( liveireland )',
    'Jazz Experimental ( sonic.soma )',
    'Country ( boot.soma )',
    'Country ( 977music )',
    'Jazz Smooth ( swissgroove )',
    'Jazz Smooth ( 1.fm )',
    'Jazz Smooth ( smoothjazz )',
    'Jazz Smooth ( 181.fm )',
    'Lovesongs ( 181.fm )',
    'Lovesongs ( slowradio )',
    'Country ( 181.fm )',
    'Country ( 1.fm )',
    'Blues ( 1.fm )',
    'Reggae ( 1.fm )',
    'Reggae ( sky )',
    'Lovesongs ( sky )',
    'Beatles tribute ( sky )',
    'Jazz Smooth ( sky )',
    'Jazz Uptempo ( sky )',
    'Flamenco ( sky )',
    'Solo piano ( sky )',
    'World ( sky )',
    'Jazz Piano ( sky )',
    'Bossanova ( sky )',
    'Soundtracks ( sky )',
    'Gospel ( sky )',
    'Salsa ( sky )',
    'Jazz Experimental ( sky )',
    'Japan/Anime ( kawaii )',
    'Japan/Anime ( armitage''s )',
    'Japan/Anime ( Anime Academy )',
    'Japan/Anime ( AnimeNfo )',
    'Games ( VGamp )',
    'Arabic ( darvish )',
    'Arabic ( mazaj )'
    );

const
  pls_misc: array[0..34] of string = (
    'http://www.liveireland.com/live.pls',
    'http://somafm.com/sonicuniverse.pls',
    'http://somafm.com/bootliquor.pls',
    'http://www.977music.com/tunein/web/country.asx',
    'http://www.swissgroove.ch/listen.m3u',
    'http://www.1.fm/jazz.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=1042&file=filename.pls',
    'http://www.181.fm/winamp.pls?station=181-breeze&bitrate=hi',
    'http://www.181.fm/winamp.pls?station=181-heart&bitrate=hi',
    'http://streams.slowradio.com/index.php?id=winamp',
    'http://www.181.fm/winamp.pls?station=181-kickincountry&bitrate=hi',
    'http://www.1.fm/country.pls',
    'http://www.1.fm/blues.pls',
    'http://www.1.fm/reggae.pls',
    'http://www.sky.fm/mp3/rootsreggae.pls',
    'http://www.sky.fm/mp3/lovemusic.pls',
    'http://www.sky.fm/mp3/beatles.pls',
    'http://www.sky.fm/mp3/smoothjazz.pls',
    'http://www.sky.fm/mp3/uptemposmoothjazz.pls',
    'http://www.sky.fm/mp3/guitar.pls',
    'http://www.sky.fm/mp3/solopiano.pls',
    'http://www.sky.fm/mp3/world.pls',
    'http://www.sky.fm/mp3/pianojazz.pls',
    'http://www.sky.fm/mp3/bossanova.pls',
    'http://www.sky.fm/mp3/soundtracks.pls',
    'http://www.sky.fm/mp3/christian.pls',
    'http://www.sky.fm/mp3/salsa.pls',
    'http://www.sky.fm/mp3/jazz.pls',
    'http://kawaii-radio.net/listen.m3u',
    'http://209.250.239.98:8676/listen.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=7504&file=filename.pls',
    'http://www.animenfo.com/radio/listen.m3u',
    'http://www.vgamp.com/listen128.pls',
    'http://207.200.96.228:8078/listen.pls',
    'http://listen.mazaj.fm/listen.pls'
    );

const
  chn_brasil: array[0..32] of string = (
    'Ecletic ( circuitomix )',
    'Ecletic ( ritmobrasil )',
    'Ecletic ( megasom )',
    'Ecletic ( radioblast )',
    'Ecletic ( tribunafm )',
    'Ecletic ( 89fm )',
    'Noticias ( cbn sp )',
    'Noticias ( cbn.rj )',
    'Noticias ( cbn.brasilia )',
    'Noticias ( cbn.bh )',
    'Noticias ( cbn.salvador )',
    'Popular ( tupi.rj )',
    'Popular ( tupi.fm )',
    'Popular ( piatafm )',
    'Classic Rock ( Kissfm )',
    'Ecletic ( redeblitz )',
    'Ecletic ( jovempan.sp)',
    'Ecletic ( radiorox )',
    'Ecletic ( hits.transamerica )',
    'Ecletic ( pop.transamerica )',
    'Ecletic ( light.transamerica )',
    'Ecletic ( japan.transamerica )',
    'Ecletic ( mixfm )',
    'Ecletic ( totalshare )',
    //
    'Ecletic ( 98fm )',
    'Ecletic ( globo.fm )',
    'Popular ( globo.am.sp )',
    'Popular ( globo.am.rj )',
    'Popular ( globo.am.mg )',
    'Rock/Metal ( sporttv )',
    'Ecletic ( multishow )',
    'Classicos ( gnt )',
    'Ecletic ( 97fm )'
    );

const
  pls_brasil: array[0..32] of string = (
    'http://www.circuitomix.com.br/circuitomix.pls',
    'http://www.ritmobrasil.com/RitmoBrasil.pls',
    'http://www.radiowebtv.com/server/megasom/megasom.m3u',
    'http://ouvir.radioblast.com.br:9000/listen.pls',
    'mms://radio.e-tribuna.com.br/tribuna',
    'http://www.89fm.com.br/aovivo/aovivo.asx',
    'http://cbn.globoradio.globo.com/cbn/wma/radiosp/asx.asp?audio=',
    'http://cbn.globoradio.globo.com/cbn/wma/radiorj/asx.asp?audio=',
    'http://cbn.globoradio.globo.com/cbn/wma/radiobsb/asx.asp?audio=',
    'http://cbn.globoradio.globo.com/cbn/wma/radiobh/asx.asp?audio=',
    'http://www.crossdigital.com.br/servidor1/8080/listen.pls',
    'mms://tupirio.interrogacaodigital.net/tupirio',
    'http://www.crosshost.com.br/cbs/tupifm/listen.pls',
    'http://198.106.109.53/radio.mp3.m3u',
    'http://www.crosshost.com.br/cbs/kiss/listen.pls',
    'http://www.redeblitz.com.br/redeblitz.m3u',
    'mms://server09.virgula.com.br/jovempanfm/',
    'http://radiorox.oi.com.br/listen.m3u',
    'mms://wmedia.telium.com.br/transsphits',
    'mms://wmedia.telium.com.br/transsppop64',
    'mms://wmedia.telium.com.br/transsplight',
    'mms://transastream.dyndns.org/transapop',
    'mms://mixstr.ig.com.br/mixfm',
    'http://radio.2streaming.info/players/8014.pls',
    //
    'http://wmsgr.globo.com/webmedia/ObterPathMidia?usuario=sgr01&tipo=live&path=/sgr_off_98fmrj_live.wma&midiaId=513694&ext.asx&output=ASX',
    'http://wmsgr.globo.com/webmedia/ObterPathMidia?usuario=sgr01&tipo=live&path=/sgr_off_globofmrj_live.wma&midiaId=505114&ext.asx&output=ASX',
    'http://wmsgr.globo.com/webmedia/ObterPathMidia?usuario=sgr01&tipo=live&path=/sgr_off_globoamsp_live.wma&midiaId=511329&ext.asx&output=ASX',
    'http://wmsgr.globo.com/webmedia/ObterPathMidia?usuario=sgr01&tipo=live&path=/sgr_off_globoamrj_live.wma&midiaId=505105&ext.asx&output=ASX',
    'http://wmsgr.globo.com/webmedia/ObterPathMidia?usuario=sgr01&tipo=live&path=/sgr_off_globoambh_live.wma&midiaId=519058&ext.asx&output=ASX',
    'http://wmsgr.globo.com/webmedia/ObterPathMidia?usuario=sgr01&tipo=live&path=/sgr_off_sportv_live.wma&midiaId=511317&ext=.asx&output=ASX',
    'http://wmsgr.globo.com/webmedia/ObterPathMidia?usuario=sgr01&tipo=live&path=/sgr_off_multishow_live.wma&midiaId=581681&ext.asx&output=ASX',
    'http://wmsgr.globo.com/webmedia/ObterPathMidia?usuario=sgr01&tipo=live&path=/sgr_off_gnt_live.wma&midiaId=510705&ext.asx&output=ASX',
    'http://relay.corptv.com.br/97fm.asp'
    );

implementation

end.

