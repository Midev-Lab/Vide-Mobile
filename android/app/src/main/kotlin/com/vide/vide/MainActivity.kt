package com.vide.vide

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val cameraPermissionChannel = "vide/camera_permissions"
    private val cameraRequestPreference = "camera_permission_request_count"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            cameraPermissionChannel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "status" -> result.success(cameraPermissionStatus())
                "preparePermissionRequest" -> {
                    val preferences = getSharedPreferences(
                        cameraPermissionChannel,
                        MODE_PRIVATE
                    )
                    preferences.edit()
                        .putInt(
                            cameraRequestPreference,
                            preferences.getInt(cameraRequestPreference, 0) + 1
                        )
                        .apply()
                    result.success(null)
                }
                "openSettings" -> {
                    val intent = Intent(
                        Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                        Uri.fromParts("package", packageName, null)
                    )
                    startActivity(intent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun cameraPermissionStatus(): String {
        if (
            ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            return "granted"
        }
        if (ActivityCompat.shouldShowRequestPermissionRationale(
                this,
                Manifest.permission.CAMERA
            )
        ) {
            return "denied"
        }

        val requestCount = getSharedPreferences(
            cameraPermissionChannel,
            MODE_PRIVATE
        ).getInt(cameraRequestPreference, 0)
        return if (requestCount >= 2) "permanentlyDenied" else "notDetermined"
    }
}
