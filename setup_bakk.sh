#!/usr/bin/env bash
set -euo pipefail

# 1) write App.js
cat > App.js <<'JS'
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
JS

# 2) write package.json
cat > package.json <<'PJ'
{
  "name": "react-native-exoplayer-player",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "android": "react-native run-android",
    "start": "react-native start",
    "build:android": "cd android && ./gradlew assembleDebug"
  },
  "dependencies": {
    "react": "18.2.0",
    "react-native": "0.71.8",
    "react-native-video": "^5.2.0",
    "react-native-gesture-handler": "^2.10.0",
    "react-native-safe-area-context": "^4.5.0",
    "react-native-orientation-locker": "^1.6.1"
  },
  "devDependencies": {
    "@babel/core": "^7.20.0",
    "@babel/runtime": "^7.20.0",
    "metro-react-native-babel-preset": "^0.74.1"
  }
}
PJ

# 3) create .github workflow
mkdir -p .github/workflows
cat > .github/workflows/android-debug.yml <<'WF'
name: Build Debug APK

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build-debug:
    runs-on: ubuntu-latest
    env:
      JAVA_HOME: /usr/lib/jvm/java-17-openjdk-amd64

    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Install Android SDK (tools + platform)
        run: |
          sudo apt-get update
          sudo apt-get install -y wget unzip
          mkdir -p $HOME/android-sdk/cmdline-tools
          cd $HOME/android-sdk
          wget https://dl.google.com/android/repository/commandlinetools-linux-110-9123335_latest.zip -O cmdline.zip
          unzip cmdline.zip -d cmdline-tools
          mv cmdline-tools/cmdline-tools cmdline-tools/latest
          export ANDROID_SDK_ROOT=$HOME/android-sdk
          yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT "platform-tools" "platforms;android-33" "build-tools;33.0.2"

      - name: Cache Gradle
        uses: actions/cache@v4
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
          key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
          restore-keys: |
            ${{ runner.os }}-gradle-

      - name: Install JS dependencies
        run: yarn install

      - name: Build debug APK
        env:
          ANDROID_SDK_ROOT: ${{ runner.home }}/android-sdk
          JAVA_HOME: /usr/lib/jvm/java-17-openjdk-amd64
        run: |
          cd android
          ./gradlew assembleDebug --no-daemon

      - name: Upload artifact (debug apk)
        uses: actions/upload-artifact@v4
        with:
          name: app-debug-apk
          path: android/app/build/outputs/apk/debug/*.apk
WF

# 4) small README
cat > README.md <<'RD'
Debug-ready React Native ExoPlayer scaffold. Generate native folder with `npx react-native init TempApp --version 0.71.8`, copy android/ into this repo, then `yarn install` and push.
RD

# 5) ANDROID_NOTES
cat > ANDROID_NOTES.txt <<'AN'
This repo is set up for debug APK building via GitHub Actions (android-debug.yml).
Local native android/ folder is required: generate with TempApp and copy android/ into this repo.
AN

# 6) generate TempApp (creates android/ folder)
echo ">>> Generating TempApp (this may take a few minutes)..."
cd "$HOME"
npx react-native init TempApp --version 0.71.8 --skip-install

# copy android folder (if exists)
if [ -d "$HOME/TempApp/android" ]; then
  echo "Copying android/ into repo..."
  cp -r "$HOME/TempApp/android" "$PWD/android"
else
  echo "TempApp android/ not found. Attempting to run npm install to finish init..."
  cd "$HOME/TempApp" || exit 1
  npm install
  cd "$PWD"
  cp -r "$HOME/TempApp/android" "$PWD/android"
fi

# 7) install JS deps
echo "Installing JS dependencies (yarn)..."
yarn install

# 8) git add, commit, push
git add .
git commit -m "Add RN ExoPlayer scaffold + android native folder"
git branch -M main || true
git push origin main

echo "All done. If git push failed, check SSH & remote permissions. You can now trigger GitHub Actions to build the debug APK."
