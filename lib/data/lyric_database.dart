class LyricDatabase {

  static final Map<String, String> _data = {
    "The 1975 - About You (Official)": """
[00:00.00]...
[00:44.85]I know a place
[00:53.98]It's somewhere I go when I need to remember your face
[01:04.20]We get married in our heads
[01:13.83]Something to do while we try to recall how we met
[01:23.72]Do you think I have forgotten?
[01:29.22]Do you think I have forgotten?
[01:33.53]Do you think I have forgotten
[01:38.66]About you?
[01:43.83]You and I (Don't let go)
[01:47.73]We're alive (Don't let go)
[01:53.23]With nothing to do, I could lay and just look in your eyes
[02:03.72]Wait (Don't let go)
[02:07.65]And pretend (Don't let go, oh)
[02:13.89]Hold on and hope that we'll find our way back in the end (In the end)
[02:23.05]Do you think I havе forgotten?
[02:28.88]Do you think I have forgotten?
[02:34.24]Do you think I havе forgotten
[02:39.15]About you?
[02:44.49]Do you think I have forgotten?
[02:48.71]Do you think I have forgotten?
[02:53.69]Do you think I have forgotten
[02:58.65]About you?
[03:03.63]And there was something about you that now I can't remember
[03:08.24]It's the same damn thing that made my heart surrender
[03:13.28]And I'll miss you on a train, I'll miss you in the mornin'
[03:19.25]I never know what to think about
[03:22.63]I think about you (Don't let go)
[03:29.42]About you (Don't let go)
[03:34.42]Do you think I have forgotten
[03:39.39]About you?
[03:44.60]About you (Don't let go, oh)
[03:49.29]About you
[03:54.68]Do you think I have forgotten
[03:59.24]About you (Don't let go)
[04:02.39]...
""",
"Hindia - Cincin (Official Lyric Video)": """
[00:00.00]...
[00:27.24] Kau bermasalah jiwa, aku pun rada gila
[00:29.60] Jodoh akal-akalan neraka, kita bersama
[00:32.88] Kau langganan menangis, lakimu muntah-muntah
[00:36.04] Begitu terus sampai Iblis tobat dan sedekah
[00:38.62] Terkadang rasanya leher terbakar hingga pagi
[00:41.97] Seperti aku hidup berpasangan dengan api
[00:45.02] Berhenti, ulangi, psikolog dan terapi
[00:49.06] Aku isi bensin, kita coba lagi
[00:52.80] Tapi sebelumnya, sejuta sayang untukmu, cinta
[00:58.23] Karena aku pun bola panas juga, kadang lebih atau sama parahnya
[01:04.27] Dan jika bicara tentang masa depan, aku pun bingung, tak punya tebakan
[01:10.49] Lagu cinta untuk akhir dunia, lihat kami nyanyikan ini bersama
[01:15.98] Semoga hidup kita terus begini-gini saja
[01:23.26] Walau sungai meluap dan kurs tak masuk logika
[01:30.30] Semoga kita mencintai apa adanya
[01:36.98] Walau katanya sekarang ku bisa masuk penjara
[01:42.70] Satu per satu, hari per hari
[01:49.72] Yang menyakiti, benahi lagi
[01:55.00] Perihal esok ‘tuk nanti dulu
[02:01.44] Perihal cincin, kucari waktu
[02:07.62] Persetan kata siapa, mau bilang apa, tak guna
[02:13.84] Mereka hanya tahu namamu, mereka takkan jadi diriku
[02:19.51] Persetan aturan cinta, tak tertulis di atas batu
[02:26.43] Apa kau ingin menjadi benar, atau ingin menjadi muda?
[02:31.80] Semoga hidup kita terus begini-gini saja
[02:38.59] Walau sungai meluap dan kurs tak masuk logika
[02:43.90] Semoga kita mencintai apa adanya
[02:50.73] Walau katanya sekarang ku bisa masuk penjara
[02:57.01] Persetan kata siapa, mau bilang apa, tak guna
[03:03.59] Mereka hanya tahu namamu, mereka takkan jadi diriku
[03:09.43] Persetan aturan cinta, tak tertulis di atas batu
[03:16.04] Apa kau ingin menjadi benar, atau ingin menjadi muda?
[03:22.56] Lagu cinta untuk akhir dunia
[03:27.50] Sekarang bantu aku nyanyikan ini Bersama
[03:33.45] Semoga hidup kita terus begini-gini saja
[03:40.07] Walau sungai meluap dan kurs tak masuk logika
[03:45.94] Semoga kita mencintai apa adanya
[03:53.26] Walau katanya sekarang ku bisa masuk penjara
[03:58.94] Satu per satu, hari per hari
[04:05.77] Yang menyakiti, benahi lagi
[04:11.39] Perihal esok ‘tuk nanti dulu
[04:17.68] Perihal cincin, kucari waktu
""",
  };
  
  static String getLyrics(String songTitle) {
    String cleantitle = songTitle.trim();
    if (_data.containsKey(cleantitle)) {
      return _data[cleantitle]!;
    }
    return "";
  }

}