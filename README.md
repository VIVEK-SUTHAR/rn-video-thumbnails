# rn-video-thumbnails

A React Native library to extract thumbnails from videos.

## Installation

```sh
npm install rn-video-thumbnails
```

## Usage

### Get Thumbnails from Video

```javascript
import { getImageAsync } from 'rn-video-thumbnails';
// ...

const options = {
  fileUri: 'path_to_your_video.mp4',
  timeInMiliSecond: 5000, // Time in milliseconds to capture the thumbnail
  quality: 0.8, // Optional: Image quality (default is 1.0)
  format: 'jpeg', // Optional: Image format ('jpeg' | 'png' | 'webp', default is 'jpeg')
};

const thumbnail = await getImageAsync(options);
console.log('Thumbnail URI:', thumbnail.uri);
console.log('Thumbnail Height:', thumbnail.height);
console.log('Thumbnail Width:', thumbnail.width);
```

## flushCache

The `flushCache` method is used to clear the cache of the rn-video-thumbnails library.

### Syntax

```javascript
import { flushCache } from 'rn-video-thumbnails';

// ...

flushCache();
```

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)