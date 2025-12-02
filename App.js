import React, {useState, useRef} from 'react';
import {
  SafeAreaView,
  View,
  Text,
  TextInput,
  TouchableOpacity,
  Modal,
  StyleSheet,
  Alert
} from 'react-native';
import Video from 'react-native-video';
import Orientation from 'react-native-orientation-locker';

export default function App(){
  const [url, setUrl] = useState('');
  const [useToken, setUseToken] = useState('');
  const [referer, setReferer] = useState('');
  const [cookies, setCookies] = useState('');
  const [userAgent, setUserAgent] = useState('');
  const [showPlayer, setShowPlayer] = useState(false);
  const [drmType, setDrmType] = useState('none');
  const [licenseServer, setLicenseServer] = useState('');
  const playerRef = useRef(null);

  const openPlayer = () => {
    if(!url){
      Alert.alert('Enter URL', 'Please enter an m3u8 / mpd / mpeg-ts / HLS / DASH URL first.');
      return;
    }
    setShowPlayer(true);
  };

  const closePlayer = () => {
    setShowPlayer(false);
    try{ Orientation.lockToPortrait(); }catch(e){}
  };

  const buildHeaders = () => {
    const headers = {};
    if(useToken) headers['Authorization'] = `Bearer ${useToken}`;
    if(referer) headers['Referer'] = referer;
    if(cookies) headers['Cookie'] = cookies;
    if(userAgent) headers['User-Agent'] = userAgent;
    return headers;
  };

  const drmConfig = () => {
    if(drmType === 'none') return undefined;
    const base = {
      type: drmType === 'clearkey' ? 'clearkey' : 'widevine',
      licenseServer: licenseServer || undefined,
      headers: buildHeaders()
    };
    return base;
  };

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.title}>ExoPlayer RN — HLS / DASH / MPD / DRM</Text>

      <View style={styles.row}>
        <Text style={styles.label}>Stream URL</Text>
        <TextInput style={styles.input} placeholder="https://example.com/stream.m3u8" value={url} onChangeText={setUrl} autoCapitalize="none" />
      </View>

      <View style={styles.row}>
        <Text style={styles.label}>Token (optional)</Text>
        <TextInput style={styles.input} placeholder="token string" value={useToken} onChangeText={setUseToken} autoCapitalize="none" />
      </View>

      <View style={styles.row}>
        <Text style={styles.label}>Referer (optional)</Text>
        <TextInput style={styles.input} placeholder="https://example.com" value={referer} onChangeText={setReferer} autoCapitalize="none" />
      </View>

      <View style={styles.row}>
        <Text style={styles.label}>Cookies (optional)</Text>
        <TextInput style={styles.input} placeholder="name=value; name2=value2" value={cookies} onChangeText={setCookies} autoCapitalize="none" />
      </View>

      <View style={styles.row}>
        <Text style={styles.label}>User-Agent (optional)</Text>
        <TextInput style={styles.input} placeholder="MyUserAgent/1.0" value={userAgent} onChangeText={setUserAgent} autoCapitalize="none" />
      </View>

      <View style={styles.row}>
        <Text style={styles.label}>DRM</Text>
        <View style={{flexDirection:'row', gap:8}}>
          <TouchableOpacity style={[styles.btn, drmType==='none' && styles.btnActive]} onPress={()=>setDrmType('none')}><Text>None</Text></TouchableOpacity>
          <TouchableOpacity style={[styles.btn, drmType==='widevine' && styles.btnActive]} onPress={()=>setDrmType('widevine')}><Text>Widevine</Text></TouchableOpacity>
          <TouchableOpacity style={[styles.btn, drmType==='clearkey' && styles.btnActive]} onPress={()=>setDrmType('clearkey')}><Text>ClearKey</Text></TouchableOpacity>
        </View>
      </View>

      {drmType !== 'none' && (
        <View style={styles.row}>
          <Text style={styles.label}>License Server</Text>
          <TextInput style={styles.input} placeholder="https://license.server/..." value={licenseServer} onChangeText={setLicenseServer} autoCapitalize="none" />
        </View>
      )}

      <TouchableOpacity style={styles.playBtn} onPress={openPlayer}>
        <Text style={styles.playBtnText}>▶ Play</Text>
      </TouchableOpacity>

      <Modal visible={showPlayer} animationType="slide" onRequestClose={closePlayer}>
        <View style={styles.playerContainer}>
          <View style={styles.topBar}>
            <TouchableOpacity onPress={closePlayer}><Text style={{color:'#fff'}}>Close</Text></TouchableOpacity>
          </View>

          <Video
            ref={playerRef}
            source={{uri: url, headers: buildHeaders()}}
            style={styles.video}
            controls={true}
            fullscreen={false}
            resizeMode="contain"
            drm={drmConfig()}
            onError={(e)=>{ console.warn('Player error', e); Alert.alert('Player error', JSON.stringify(e)); }}
            onLoad={()=>{ try{ Orientation.lockToLandscape(); }catch(e){} }}
            onFullscreenPlayerWillPresent={()=>{ Orientation.lockToLandscape(); }}
            onFullscreenPlayerWillDismiss={()=>{ Orientation.lockToPortrait(); }}
          />

          <View style={styles.info}>
            <Text style={{color:'#fff'}}>URL: {url}</Text>
            <Text style={{color:'#fff'}}>DRM: {drmType}</Text>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container:{flex:1, padding:16, backgroundColor:'#121212'},
  title:{fontSize:18, fontWeight:'600', color:'#fff', marginBottom:12},
  row:{marginBottom:10},
  label:{color:'#ddd', marginBottom:6},
  input:{backgroundColor:'#222', color:'#fff', padding:10, borderRadius:6},
  btn:{padding:8, backgroundColor:'#333', borderRadius:6, marginRight:8},
  btnActive:{backgroundColor:'#0a84ff'},
  playBtn:{marginTop:12, backgroundColor:'#0a84ff', padding:12, borderRadius:8, alignItems:'center'},
  playBtnText:{color:'#fff', fontSize:16, fontWeight:'600'},
  playerContainer:{flex:1, backgroundColor:'#000'},
  topBar:{height:56, justifyContent:'center', paddingHorizontal:12, backgroundColor:'rgba(0,0,0,0.6)'},
  video:{flex:1, backgroundColor:'#000'},
  info:{padding:12}
});
