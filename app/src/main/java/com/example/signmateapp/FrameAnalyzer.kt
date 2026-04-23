package com.example.signmateapp

import android.app.Activity
import android.graphics.Bitmap
import android.graphics.ImageFormat
import android.graphics.YuvImage
import android.util.Log
import android.widget.TextView
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker.HandLandmarkerOptions
import java.io.ByteArrayOutputStream
import java.io.FileInputStream
import java.nio.channels.FileChannel

class FrameAnalyzer(
    private val activity: Activity,
    private val textView: TextView
) : ImageAnalysis.Analyzer {

    private lateinit var interpreter: org.tensorflow.lite.Interpreter

    private val handLandmarker: HandLandmarker by lazy {
        val options = HandLandmarkerOptions.builder()
            .setBaseOptions(
                BaseOptions.builder()
                    .setModelAssetPath("hand_landmarker.task")
                    .build()
            )
            .setRunningMode(RunningMode.IMAGE)
            .build()

        HandLandmarker.createFromOptions(activity, options)
    }

    init {
        try {
            val fileDescriptor = activity.assets.openFd("model.tflite")
            val inputStream = FileInputStream(fileDescriptor.fileDescriptor)
            val fileChannel = inputStream.channel

            val model = fileChannel.map(
                FileChannel.MapMode.READ_ONLY,
                fileDescriptor.startOffset,
                fileDescriptor.declaredLength
            )
            interpreter = org.tensorflow.lite.Interpreter(model)
        } catch (e: Exception) {
            Log.e("FrameAnalyzer", "Error initializing TFLite: ${e.message}")
        }
    }

    override fun analyze(image: ImageProxy) {
        val bitmap = imageProxyToBitmap(image)

        if (bitmap != null) {
            try {
                val mpImage = BitmapImageBuilder(bitmap).build()
                val result = handLandmarker.detect(mpImage)

                if (result.landmarks().isNotEmpty()) {
                    val lm = result.landmarks()[0]

                    val input = Array(1) { FloatArray(42) }
                    for (i in lm.indices) {
                        input[0][i * 2] = lm[i].x()
                        input[0][i * 2 + 1] = lm[i].y()
                    }

                    val output = Array(1) { FloatArray(3) }
                    interpreter.run(input, output)

                    val index = output[0].indices.maxByOrNull { output[0][it] } ?: 0
                    val gujarati = when (index) {
                        0 -> "A"
                        1 -> "B"
                        else -> "C"
                    }

                    activity.runOnUiThread {
                        textView.text = gujarati
                    }
                }
            } catch (e: Exception) {
                Log.e("FrameAnalyzer", "Analysis error: ${e.message}")
            }
        }
        image.close()
    }

    private fun imageProxyToBitmap(image: ImageProxy): Bitmap? {
        val yBuffer = image.planes[0].buffer
        val uBuffer = image.planes[1].buffer
        val vBuffer = image.planes[2].buffer

        val ySize = yBuffer.remaining()
        val uSize = uBuffer.remaining()
        val vSize = vBuffer.remaining()

        val nv21 = ByteArray(ySize + uSize + vSize)

        yBuffer.get(nv21, 0, ySize)
        vBuffer.get(nv21, ySize, vSize)
        uBuffer.get(nv21, ySize + vSize, uSize)

        val yuvImage = YuvImage(nv21, ImageFormat.NV21, image.width, image.height, null)

        val out = ByteArrayOutputStream()
        yuvImage.compressToJpeg(
            android.graphics.Rect(0, 0, image.width, image.height),
            100,
            out
        )

        val bytes = out.toByteArray()
        return android.graphics.BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
    }
}
