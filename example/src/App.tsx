import * as React from 'react';
import { Button, Image, StyleSheet, View } from 'react-native';
import DocumentPicker from 'react-native-document-picker';
import { getImageAsync, flushCache } from 'rn-video-thumbnails';

export default function App() {
  const [thumbnail, setthumbnail] = React.useState<null | string>();

  function getImage() {
    DocumentPicker.pickSingle({ type: [DocumentPicker.types.video] })
      .then((res) => {
        extractThumbnail(res.uri);
      })
      .catch((err) => {
        console.log(err);
      });
  }

  async function extractThumbnailFromHTTPUrl() {
    try {
      const startTime = performance.now();
      const httpUrl =
        'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4';
      const image = await getImageAsync({
        fileUri: httpUrl,
        timeInMiliSecond: 1000,
      });
      const endTime = performance.now();
      console.log(`Took ${endTime - startTime} ms`);
      setthumbnail(image.uri);
    } catch (error) {
      console.log(error);
    }
  }

  function extractThumbnail(uri: string) {
    const startTime = performance.now();
    getImageAsync({
      fileUri: uri,
      timeInMiliSecond: 500,
    })
      .then((res) => {
        const endTime = performance.now();
        console.log(`Took ${endTime - startTime} ms`);
        console.log(res);
        setthumbnail(res.uri);
      })
      .catch((err) => {
        console.log(err);
        if (err instanceof Error) {
          console.log(err.name);
          console.log(err.message);
        }
      });
  }
  const clearCacheFiles = () => {
    flushCache()
      .then((res) => {
        console.log(res);
      })
      .catch((e) => {
        console.log(e);
      });
  };
  return (
    <View style={styles.container}>
      <View style={styles.my}>
        <Button title="Select Video and Extract" onPress={getImage} />
      </View>
      <View style={styles.my}>
        <Button
          title="Extract from a HTTP Video"
          onPress={extractThumbnailFromHTTPUrl}
        />
      </View>
      <View style={styles.my}>
        <Button title="Clear Cache Files" onPress={clearCacheFiles} />
      </View>
      {thumbnail && (
        <Image source={{ uri: thumbnail }} style={styles.imageStyle} />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
  my: {
    marginVertical: 20,
  },
  imageStyle: {
    height: 200,
    width: 200,
    resizeMode: 'contain',
  },
});
