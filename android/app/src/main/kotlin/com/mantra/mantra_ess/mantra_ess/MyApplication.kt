package com.mantra.mantra_ess.mantra_ess

import io.flutter.app.FlutterApplication
import com.google.mlkit.common.MlKit

class MyApplication : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        MlKit.initialize(this)
    }
}
