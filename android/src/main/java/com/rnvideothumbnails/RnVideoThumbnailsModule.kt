package com.rnvideothumbnails

import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.util.Log
import android.webkit.URLUtil
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.util.UUID


class RnVideoThumbnailsModule internal constructor(context: ReactApplicationContext) :
  RnVideoThumbnailsSpec(context) {
  private val mContext:ReactApplicationContext=context
  override fun getName(): String {
    return NAME
  }
  @ReactMethod
  override fun getImageAsync(options:ReadableMap,promise: Promise) {
    val videoFilePath: String? = options.getString ("fileUri")
    val time: Double = options.getDouble("timeInMiliSecond")
    val quality: Int = options.getInt("quality")
    val format: String? = options.getString("format")
    
    Log.d(NAME, "videoFilePath:$videoFilePath")
    Log.d(NAME, "Format: $format")
    val extractor=MediaMetadataRetriever();
    if(URLUtil.isFileUrl(videoFilePath) || URLUtil.isHttpsUrl((videoFilePath)) || URLUtil.isHttpUrl((videoFilePath))){
      extractor.setDataSource(videoFilePath)
    }
    else if(URLUtil.isContentUrl(videoFilePath)){
      val originalFileUri=Uri.parse(videoFilePath)
      val fileDescriptor = mContext.contentResolver.openFileDescriptor(originalFileUri, "r")!!.fileDescriptor
      FileInputStream(fileDescriptor).use { inputStream->
        extractor.setDataSource(inputStream.fd)
      }
    }
    val extractedImage=extractor.getFrameAtTime(time.toLong()*1000,MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
    val outputPath=createFile().absolutePath;
    if (extractedImage != null) {
      FileOutputStream(outputPath).use { outputStream ->
        extractedImage.compress(Bitmap.CompressFormat.JPEG,quality,outputStream)
      }
    }
    val outputObject=Arguments.createMap()
    outputObject.putString("uri",Uri.fromFile(File(outputPath)).toString())
    if (extractedImage != null) {
      outputObject.putInt("width",extractedImage.width)
      outputObject.putInt("height",extractedImage.height)
    }
    promise.resolve(outputObject)
  }

  private  fun  createFile():File {
    val fileName = "$NAME" + UUID.randomUUID().toString();
      val file = File(
        mContext.getExternalCacheDir(),
        "${NAME}_$fileName"
      )
      check(!(file.exists() && !file.delete())) { "Could not delete the previous export output file" }
      check(file.createNewFile()) { "Could not create the export output file" }
      return file
  }

  @ReactMethod
  override  fun flushCacheFiles(
    promise: Promise
  ) {
    try {
      val filePrefix = NAME
      var filesDeleted = 0
      val cacheDirectory: File? = mContext.getExternalCacheDir()
      if (cacheDirectory == null || !cacheDirectory.exists()) {
        promise.reject("Cache directory doesn't exist ")
        return
      }
      val cacheFiles = cacheDirectory.listFiles()
      if (cacheFiles == null) {
        promise.reject("Looks like there is no cache files")
        return
      }
      for (file in cacheFiles) {
        if (file.name.startsWith(filePrefix)) {
          if (file.delete()) {
            filesDeleted++
          }
        }
      }
      val message =
        if (filesDeleted > 0) "Cleared cache, $filesDeleted files deleted" else "There is no files in cache to delete"
      promise.resolve(message)
    } catch (e: Exception) {
      Log.e(ERROR_TAG, "Failed to delete cache files", e)
      promise.reject("Failed to delete cache files")
    }
  }

  companion object {
    const val NAME = "RnVideoThumbnails"
    const val ERROR_TAG = "E_RnVideoThumbnails"
  }
}
