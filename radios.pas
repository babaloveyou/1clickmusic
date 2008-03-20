unit radios;

interface

const
  ELETRONIC = 0;
  ROCKMETAL = 1;
  ECLETIC = 2;
  HIPHOP = 3;
  OLDMUSIC = 4;
  INDUSTRIAL = 5;
  MISC = 6;
  BRASIL = 7;

const
  genrelist: array[0..7] of string = (
    'Eletronic',
    'Rock / Metal',
    'Ecletic',
    'Hip-Hop',
    '80''s / 90''s / Classic',
    'Industrial',
    'Others',
    'Brasil (BETA)'
    );

const
  chn_eletronic: array[0..71] of string = (
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
    'Lounge ( 1.fm )',
    'Club ( 1.fm )',
    'Dance ( 1.fm )',
    'Chillout ( 1.fm )',
    'Funky House ( rautemusik )',
    'Lounge ( rautemusik )',
    'Progressive ( soma )',
    'Ambient ( groove.soma )',
    'Ambient ( space.soma )',
    'Ambient ( drone.soma )',
    'Ambient ( blender.soma )',
    'Psytrance ( philosomatika )',
    'Psytrance ( psyradio )',
    'Psyprog ( psyradio )',
    'Chillout ( psyradio )',
    'Minimal ( psyradio )',
    'Trance ( neradio )',
    'Drum''and''Bass ( dnbradio )',
    'Drum''and''Bass ( bassdrive)',
    'Electro House ( DI )',
    'Tribal House ( DI )',
    'Funky House ( DI )',
    'Minimal ( DI )',
    'Hardstyle ( DI )',
    'Trance ( DI )',
    'Vocal Trance ( DI )',
    'Chillout ( DI )',
    'Eurodance ( DI )',
    'House ( DI )',
    'Soulfulhouse ( DI )',
    'Harddance ( DI )',
    'Techno ( DI )',
    'Progressive ( DI )',
    'Psytrance ( DI )',
    'Hardcore ( DI )',
    'DJ-Mixes ( DI )',
    'Lounge ( DI )',
    'Drum''and''Bass ( DI )',
    'Cassic Techno ( DI )',
    'Ambient ( DI )',
    'BreakBeat ( DI )',
    'Futurepop ( DI )',
    'Gabber ( DI )',
    'Jumpstyle ( imusicfm )',
    'Jumpstyle/Hardstyle ( fear )',
    'Hardstyle/Hardcore ( fear )',
    'BreakBeat ( chn1.breaksfm )',
    'BreakBeat ( chn2.breaksfm )',
    'Chillout ( bluefm )',
    'Dance ( 181.fm )',
    'Chillout ( 181.fm )',
    'Psytrance Mixes ( psychedelik )',
    'Psytrance ( psychedelik )',
    'Psyprog ( psychedelik )',
    'Chillout ( psychedelik )',
    'DarkPsy ( psychedelik )',
    'DarkPsy ( triplag )',
    'DarkPsybient ( triplag )',
    'Dance ( frisky )',
    'Club ( RaveTrax )',
    'Dance ( FG Radio )',
    'Dance ( ibizaglobal )'
    );

const
  pls_eletronic: array[0..71] of string = (
    'http://stats.ah.fm/dynamicplaylist.m3u?quality=96',
    'http://blitz-stream.de/stream/stream.m3u',
    'http://www.playdio.se/bredband.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=2882&file=filename.pls',
    'http://listen.to.techno4ever.net/dsl/mp3',
    'http://www.pulsradio.com/pls/puls-adsl.m3u',
    'http://dsl.technobase.eu/listen-dsl.pls',
    'http://88.191.35.197/listen.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=5438&file=filename.pls',
    'http://club-office.rautemusik.de/listen.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=402939&file=filename.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=6057&file=filename.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=6201&file=filename.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=6951&file=filename.pls',
    'http://funky-office.rautemusik.de/listen.pls',
    'http://lounge-office.rautemusik.de/listen.pls',
    'http://somafm.com/tagstrance.pls',
    'http://somafm.com/groovesalad.pls',
    'http://somafm.com/spacestation.pls',
    'http://somafm.com/dronezone.pls',
    'http://somafm.com/beatblender.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=1712&file=filename.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=3644&file=filename.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=2006&file=filename.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=892&file=filename.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=5293&file=filename.pls',
    'http://www.neradio.se/listen.pls',
    'http://www.dnbradio.com/hi.pls',
    'http://www.bassdrive.com/v2/streams/BassDrive.pls',
    'http://www.di.fm/mp3/electro.pls',
    'http://www.di.fm/mp3/tribalhouse.pls',
    'http://www.di.fm/mp3/funkyhouse.pls',
    'http://www.di.fm/mp3/minimal.pls',
    'http://www.di.fm/mp3/hardstyle.pls',
    'http://www.di.fm/mp3/trance.pls',
    'http://www.di.fm/mp3/vocaltrance.pls',
    'http://www.di.fm/mp3/chillout.pls',
    'http://www.di.fm/mp3/eurodance.pls',
    'http://www.di.fm/mp3/house.pls',
    'http://www.di.fm/mp3/soulfulhouse.pls',
    'http://www.di.fm/mp3/harddance.pls',
    'http://www.di.fm/mp3/techno.pls',
    'http://www.di.fm/mp3/progressive.pls',
    'http://www.di.fm/mp3/goapsy.pls',
    'http://www.di.fm/mp3/hardcore.pls',
    'http://www.di.fm/mp3/djmixes.pls',
    'http://www.di.fm/mp3/lounge.pls',
    'http://www.di.fm/mp3/drumandbass.pls',
    'http://www.di.fm/mp3/classictechno.pls',
    'http://www.di.fm/mp3/ambient.pls',
    'http://www.di.fm/mp3/breaks.pls',
    'http://www.di.fm/mp3/futuresynthpop.pls',
    'http://www.di.fm/mp3/gabber.pls',
    'http://www.imusicfm.nl/listen.pls',
    'http://internetradio.fearfm.nl/customplayer/fearfm_hard_high.pls',
    'http://internetradio.fearfm.nl/customplayer/fearfm_harder_high.pls',
    'http://www.breaksfm.com/breaksfm/hifi.m3u',
    'http://www.breaksfm.com/breaksfm/hifi2.m3u',
    'http://bluefm.net/listen.pls',
    'http://www.181.fm/winamp.pls?station=181-energy98&bitrate=hi',
    'http://www.181.fm/winamp.pls?station=181-chilled&bitrate=hi',
    'http://88.191.15.43:8020/listen.pls',
    'http://88.191.38.140:8000/listen.pls',
    'http://88.191.38.140:8002/listen.pls',
    'http://88.191.38.140:8010/listen.pls',
    'http://88.191.38.140:8014/listen.pls',
    'http://www.triplag.com/webradio/darkpsy/triplag-darkpsy.php',
    'http://www.triplag.com/webradio/chilltrip/triplag-chilltrip.php',
    'http://www.friskyradio.com/frisky.m3u',
    'http://ravetrax.com/mp3_hi.pls',
    'http://fg.impek.tv/listen.pls',
    'http://s6.viastreaming.net:7010/listen.pls'
    );

const
  chn_rockmetal: array[0..21] of string = (
    'Indie Rock ( soma )',
    'Punk Rock ( idobi )',
    'Classic Rock ( 977music )',
    'Alternative ( 977music )',
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
    'Alternative ( the buzz.1.fm )',
    'Rock/Metal ( channel x.1.fm )',
    'Rock/Metal ( high voltage.1.fm )',
    'Rock/Metal ( metalonly )',
    'Rock/Metal ( kinkfm )',
    'Rock/Metal ( gothmetal )',
    'Classic Rock ( rock&rollfm )'
    );

const
  pls_rockmetal: array[0..21] of string = (
    'http://somafm.com/indiepop.pls',
    'http://www.idobi.com/radio/iradio.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=8854&file=filename.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=4278&file=filename.pls',
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
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=8591&file=filename.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=9592&file=filename.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=890786&file=filename.pls',
    'http://metal-only.de/listen.pls',
    'http://www.kinkfm.com/streams/kink_aardschok.m3u',
    'http://82.134.68.36:7999/listen.pls',
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
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=9462&file=filename.pls',
    'http://www.sky.fm/mp3/tophits.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=6409&file=filename.pls',
    'http://www.977music.com/tunein/web/hitz.asx',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=9956&file=filename.pls',
    'http://www.181.fm/winamp.pls?station=181-power&bitrate=hi',
    'http://www.181.fm/winamp.pls?station=181-themix&bitrate=hi',
    'http://www.181.fm/winamp.pls?station=181-thepoint&bitrate=hi',
    'http://www.181.fm/winamp.pls?station=181-party&bitrate=hi',
    'http://main-office.rautemusik.de/listen.pls',
    'http://www.hitzradio.com/hitzradio.pls'
    );

const
  chn_hiphop: array[0..7] of string = (
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
  pls_hiphop: array[0..7] of string = (
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
  chn_oldmusic: array[0..15] of string = (
    '60''s ( sky )',
    '70''s ( sky )',
    '80''s ( sky )',
    '60''s - 70''s ( 181.fm)',
    '80''s ( awesome.181.fm )',
    '80''s ( lite.181.fm )',
    '90''s ( 181.fm )',
    '80''s ( 977music )',
    '90''s ( 977music )',
    '50''s - 80''s ( RauteMusik )',
    'Oldies ( sky )',
    'Baroque ( 1.fm )',
    'Opera ( 1.fm )',
    'Classical ( 1.fm )',
    '80''s ( asf )',
    '80''s ( chaos )'
    );

const
  pls_oldmusic: array[0..15] of string = (
    'http://www.sky.fm/mp3/oldies.pls',
    'http://www.sky.fm/mp3/hit70s.pls',
    'http://www.sky.fm/mp3/the80s.pls',
    'http://www.181.fm/winamp.pls?station=181-greatoldies&bitrate=hi',
    'http://www.181.fm/winamp.pls?station=181-awesome80s&bitrate=hi',
    'http://www.181.fm/winamp.pls?station=181-lite80s&bitrate=hi',
    'http://www.181.fm/winamp.pls?station=181-star90s&bitrate=hi',
    'http://www.977music.com/tunein/web/80s.asx',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=3306&file=filename.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=6422&file=filename.pls',
    'http://www.sky.fm/mp3/classical.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=4899&file=filename.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=285260&file=filename.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=7790&file=filename.pls',
    'http://www.atlanticsoundfactory.com/asfbb.pls',
    'http://www.chaos-radio.net/stream/listen.m3u'
    );

const
  chn_industrial: array[0..8] of string = (
    // 'Post Industrial ( darksection )',
    'Post Industrial ( tormented )',
    'Post Industrial ( digitalgunfire )',
    'Post Industrial ( ultradark )',
    'Post Industrial ( ebmradio )',
    // 'Post Industrial ( schwarze )',
    'Post Industrial ( r1live )',
    'Post Industrial ( rantradio )',
    'Post Industrial ( realindustrial )',
    'Post Industrial ( vampirefreaks )',
    'Ambient Industrial ( somafm )'
    );

const
  pls_industrial: array[0..8] of string = (
    // 'http://dark-section.de/streams/winamp_128.pls',
    'http://playlist.tormentedradio.com/radioG.pls',
    'http://www.digitalgunfire.com/playlist.pls',
    'http://www.ultradarkradio.com/listen.pls',
    'http://www.ebm-radio.de/tunein/listen.pls',
    // 'http://www.schwarze-welle.com/play.m3u',
    'http://www.r1live.de/player/winamp.pls',
    'http://www.rantmedia.ca/industrial/rr-industrial128.pls',
    'http://radio.realindustrialradio.com:8000/listen.pls',
    'http://vfradio.com/listen/8000.m3u',
    'http://somafm.com/doomed.pls'
    );

const
  chn_misc: array[0..35] of string = (
    'Experimental Jazz ( sonic.soma )',
    'Country ( boot.soma )',
    'Country ( 977music )',
    'Comedy ( 977music )',
    'Downtempo lounge ( swissgroove )',
    'Smoothjazz ( 1.fm )',
    'Smoothjazz ( smoothjazz )',
    'Smoothjazz ( 181.fm )',
    'Lovesongs ( 181.fm )',
    'Country ( 181.fm )',
    'Country ( 1.fm )',
    'Blues ( 1.fm )',
    'Reggae ( 1.fm )',
    'Reggae ( sky )',
    'Lovesongs ( sky )',
    'Beatles tribute ( sky )',
    'Smoothjazz ( sky )',
    'Uptempo smooth jazz ( sky )',
    'Flamenco ( sky )',
    'Solo piano ( sky )',
    'Newage ( sky )',
    'World ( sky )',
    'Downtempo lounge ( sky )',
    'Piano jazz ( sky )',
    'Bossanova ( sky )',
    'Soundtracks ( sky )',
    'Gospel ( sky )',
    'Salsa ( sky )',
    'Nu Jazz ( sky )',
    'Japan/Anime ( kawaii )',
    'Japan/Anime ( armitage''s )',
    'Japan/Anime ( Anime Academy )',
    'Japan/Anime ( AnimeNfo )',
    'Games ( VGamp )',
    'Arabic ( darvish )',
    'Arabic ( mazaj )'
    );

const
  pls_misc: array[0..35] of string = (
    'http://somafm.com/sonicuniverse.pls',
    'http://somafm.com/bootliquor.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=2338&file=filename.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=2135&file=filename.pls',
    'http://www.swissgroove.ch/listen.m3u',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=3654&file=filename.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=1042&file=filename.pls',
    'http://www.181.fm/winamp.pls?station=181-breeze&bitrate=hi',
    'http://www.181.fm/winamp.pls?station=181-heart&bitrate=hi',
    'http://www.181.fm/winamp.pls?station=181-kickincountry&bitrate=hi',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=5835&file=filename.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=2701&file=filename.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=1876&file=filename.pls',
    'http://www.sky.fm/mp3/rootsreggae.pls',
    'http://www.sky.fm/mp3/lovemusic.pls',
    'http://www.sky.fm/mp3/beatles.pls',
    'http://www.sky.fm/mp3/smoothjazz.pls',
    'http://www.sky.fm/mp3/uptemposmoothjazz.pls',
    'http://www.sky.fm/mp3/guitar.pls',
    'http://www.sky.fm/mp3/solopiano.pls',
    'http://www.sky.fm/mp3/newage.pls',
    'http://www.sky.fm/mp3/world.pls',
    'http://www.sky.fm/mp3/datempolounge.pls',
    'http://www.sky.fm/mp3/pianojazz.pls',
    'http://www.sky.fm/mp3/bossanova.pls',
    'http://www.sky.fm/mp3/soundtracks.pls',
    'http://www.sky.fm/mp3/christian.pls',
    'http://www.sky.fm/mp3/salsa.pls',
    'http://www.sky.fm/mp3/jazz.pls',
    'http://kawaii-radio.net/listen.m3u',
    'http://216.32.85.51:8000/listen.pls',
    'http://www.shoutcast.com/sbin/shoutcast-playlist.pls?rn=7504&file=filename.pls',
    'http://www.animenfo.com/radio/listen.m3u',
    'http://www.vgamp.com/listen128.pls',
    'http://207.200.96.228:8078/listen.pls',
    'http://listen.mazaj.fm/listen.pls'
    );

const
  chn_brasil: array[0..13] of string = (
    'Popular ( tupi - 104.1fm)',
    'Popular ( piatafm )',
    'Classic Rock ( Kissfm )',
    'Ecletic ( jovampan sp)',
    'Ecletic ( radiorox )',
    'Ecletic ( hits.transamerica )',
    'Ecletic ( pop.transamerica )',
    'Ecletic ( light.transamerica )',
    'Ecletic ( japan.transamerica )',
    'Ecletic ( mixfm )',
    'Ecletic ( totalshare )',
    // radios da globo
    'Rock/Metal ( sporttv )',
    'Ecletic ( multishow )',
    'Classicos ( gnt )'

    );

const
  pls_brasil: array[0..13] of string = (
    'http://www.crosshost.com.br/cbs/tupifm/listen.pls',
    'http://www.piatafm.com.br/radio.mp3.m3u',
    'http://www.crosshost.com.br/cbs/kiss/listen.pls',
    'mms://server09.virgula.com.br/jovempanfm/',
    'http://radiorox.oi.com.br/listen.m3u',
    'mms://wmedia.telium.com.br/transsphits',
    'mms://wmedia.telium.com.br/transsppop64',
    'mms://wmedia.telium.com.br/transsplight',
    'mms://transastream.dyndns.org/transapop',
    'mms://mixstr.ig.com.br/mixfm',
    'http://radio.2streaming.info:8014',
    // radios da globo
    'http://wmsgr.globo.com/webmedia/ObterPathMidia?usuario=sgr01&tipo=live&path=/sgr_off_sportv_live.wma&midiaId=511317&ext=.asx&output=ASX',
    'http://wmsgr.globo.com/webmedia/ObterPathMidia?usuario=sgr01&tipo=live&path=/sgr_off_multishow_live.wma&midiaId=581681&ext.asx&output=ASX',
    'http://wmsgr.globo.com/webmedia/ObterPathMidia?usuario=sgr01&tipo=live&path=/sgr_off_gnt_live.wma&midiaId=510705&ext.asx&output=ASX'
    );

implementation

end.

