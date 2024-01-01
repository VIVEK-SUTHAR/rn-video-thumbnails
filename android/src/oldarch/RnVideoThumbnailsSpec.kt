package com.rnvideothumbnails

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReadableMap

abstract class RnVideoThumbnailsSpec internal constructor(context: ReactApplicationContext) :
  ReactContextBaseJavaModule(context) {

  abstract fun getImageAsync(options:ReadableMap,promise: Promise)

  abstract fun flushCacheFiles(promise: Promise)
}
