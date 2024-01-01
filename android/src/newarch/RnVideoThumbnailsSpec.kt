package com.rnvideothumbnails

import com.facebook.react.bridge.ReactApplicationContext

abstract class RnVideoThumbnailsSpec internal constructor(context: ReactApplicationContext) :
  NativeRnVideoThumbnailsSpec(context) {

    abstract fun getImageAsync(options:ReadableMap,promise: Promise)

    abstract fun flushCacheFiles(promise: Promise)
}
