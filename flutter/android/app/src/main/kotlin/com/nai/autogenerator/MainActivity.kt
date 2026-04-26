package com.nai.autogenerator

import android.content.ContentValues
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.text.TextUtils
import android.webkit.MimeTypeMap
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

class MainActivity : FlutterActivity() {
    private val saveChannel = "com.nai.autogenerator/image_save"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, saveChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveImageBytes" -> {
                        val bytes = call.argument<ByteArray>("bytes")
                        val fileName = call.argument<String>("fileName")
                        val extension = call.argument<String>("extension")
                        val relativePath = call.argument<String>("relativePath")
                        result.success(
                            saveImageBytes(
                                bytes,
                                fileName,
                                extension,
                                relativePath
                            )
                        )
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun saveImageBytes(
        bytes: ByteArray?,
        fileName: String?,
        extension: String?,
        relativePath: String?
    ): HashMap<String, Any?> {
        if (bytes == null || bytes.isEmpty() || fileName.isNullOrBlank()) {
            return saveResult(false, null, "parameters error")
        }

        val safeExtension = extension?.lowercase()?.trim('.') ?: "png"
        val displayName = "$fileName.$safeExtension"
        val mimeType = getMimeType(safeExtension)

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            saveWithMediaStore(bytes, displayName, mimeType, relativePath)
        } else {
            saveLegacy(bytes, displayName, relativePath)
        }
    }

    private fun saveWithMediaStore(
        bytes: ByteArray,
        displayName: String,
        mimeType: String?,
        relativePath: String?
    ): HashMap<String, Any?> {
        val path = sanitizeRelativePicturesPath(relativePath)
        val values = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, displayName)
            put(MediaStore.Images.Media.RELATIVE_PATH, path)
            if (!TextUtils.isEmpty(mimeType)) {
                put(MediaStore.Images.Media.MIME_TYPE, mimeType)
            }
            put(MediaStore.Images.Media.IS_PENDING, 1)
        }

        var uri: Uri? = null
        return try {
            uri = contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                ?: return saveResult(false, null, "Failed to create MediaStore item")

            contentResolver.openOutputStream(uri)?.use { output ->
                output.write(bytes)
                output.flush()
            } ?: return saveResult(false, null, "Failed to open output stream")

            ContentValues().apply {
                put(MediaStore.Images.Media.IS_PENDING, 0)
            }.also { pendingValues ->
                contentResolver.update(uri, pendingValues, null, null)
            }

            saveResult(true, uri.toString(), null)
        } catch (e: IOException) {
            uri?.let { contentResolver.delete(it, null, null) }
            saveResult(false, null, e.toString())
        } catch (e: Exception) {
            uri?.let { contentResolver.delete(it, null, null) }
            saveResult(false, null, e.toString())
        }
    }

    private fun saveLegacy(
        bytes: ByteArray,
        displayName: String,
        relativePath: String?
    ): HashMap<String, Any?> {
        val picturesDir = Environment.getExternalStoragePublicDirectory(
            Environment.DIRECTORY_PICTURES
        )
        val childPath = sanitizeRelativePicturesPath(relativePath)
            .removePrefix(Environment.DIRECTORY_PICTURES)
            .trim('/')
        val targetDir = if (childPath.isEmpty()) picturesDir else File(picturesDir, childPath)

        return try {
            if (!targetDir.exists()) {
                targetDir.mkdirs()
            }
            val file = uniqueFile(targetDir, displayName)
            FileOutputStream(file).use { output ->
                output.write(bytes)
                output.flush()
            }
            MediaScannerConnection.scanFile(this, arrayOf(file.absolutePath), null, null)
            saveResult(true, file.absolutePath, null)
        } catch (e: IOException) {
            saveResult(false, null, e.toString())
        }
    }

    private fun uniqueFile(directory: File, displayName: String): File {
        val dotIndex = displayName.lastIndexOf('.')
        val name = if (dotIndex > 0) displayName.substring(0, dotIndex) else displayName
        val extension = if (dotIndex > 0) displayName.substring(dotIndex) else ""
        var file = File(directory, displayName)
        var index = 1
        while (file.exists()) {
            file = File(directory, "${name}_$index$extension")
            index++
        }
        return file
    }

    private fun getMimeType(extension: String): String? {
        return MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)
    }

    private fun sanitizeRelativePicturesPath(path: String?): String {
        val fallback = "${Environment.DIRECTORY_PICTURES}/NAIApp"
        if (path.isNullOrBlank()) return fallback

        val cleaned = path.replace("\\", "/")
            .split("/")
            .map { it.trim() }
            .filter { it.isNotEmpty() }
            .joinToString("/")

        if (cleaned.isBlank()) return fallback
        return if (cleaned.startsWith(Environment.DIRECTORY_PICTURES)) {
            cleaned
        } else {
            "${Environment.DIRECTORY_PICTURES}/$cleaned"
        }
    }

    private fun saveResult(
        isSuccess: Boolean,
        filePath: String?,
        errorMessage: String?
    ): HashMap<String, Any?> {
        return hashMapOf(
            "isSuccess" to isSuccess,
            "filePath" to filePath,
            "errorMessage" to errorMessage
        )
    }
}
