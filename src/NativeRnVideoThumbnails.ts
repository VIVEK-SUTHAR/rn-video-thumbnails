import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';
import type { GetImageOptions } from 'rn-video-thumbnails';

export interface Spec extends TurboModule {
  getImageAsync: (options: GetImageOptions) => Promise<string>;
  flushCacheFiles: () => Promise<void>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('RnVideoThumbnails');
