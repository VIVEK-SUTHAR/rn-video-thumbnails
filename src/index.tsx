import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'rn-video-thumbnails' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

// @ts-expect-error
const isTurboModuleEnabled = global.__turboModuleProxy != null;

const RnVideoThumbnailsModule = isTurboModuleEnabled
  ? require('./NativeRnVideoThumbnails').default
  : NativeModules.RnVideoThumbnails;

const RnVideoThumbnails = RnVideoThumbnailsModule
  ? RnVideoThumbnailsModule
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export type GetImageOptions = {
  fileUri: string;
  timeInMiliSecond: number;
  quality?: number;
  format?: 'jpeg' | 'png' | 'webp';
};

export type ImageResponse = {
  uri: string;
  height?: number;
  width?: number;
};
export function getImageAsync(
  options: GetImageOptions
): Promise<ImageResponse> {
  const defaultOptions = {
    quality: 100,
    format: 'jpeg',
  };
  const userOptions = {
    ...defaultOptions,
    ...options,
  };
  return RnVideoThumbnails.getImageAsync(userOptions);
}

export function flushCache(): Promise<string> {
  return RnVideoThumbnails.flushCacheFiles();
}
