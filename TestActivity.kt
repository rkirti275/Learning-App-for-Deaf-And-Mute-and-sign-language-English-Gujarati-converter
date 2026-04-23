package com.example.signmateapp

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import androidx.appcompat.app.AppCompatActivity

class TestActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_test)

        val btnCamera = findViewById<Button>(R.id.btnCameraTest)
        val btnMCQ = findViewById<Button>(R.id.btnMCQTest)
        val tvTestTitle = findViewById<android.widget.TextView>(R.id.tvTestTitle)
        val tvTestSubtitle = findViewById<android.widget.TextView>(R.id.tvTestSubtitle)

        // Load animations
        val bounceAnim = android.view.animation.AnimationUtils.loadAnimation(this, R.anim.bounce)
        val slideUpAnim = android.view.animation.AnimationUtils.loadAnimation(this, R.anim.slide_up)

        // Start animations
        tvTestTitle?.startAnimation(bounceAnim)
        tvTestSubtitle?.startAnimation(slideUpAnim)
        btnCamera?.startAnimation(slideUpAnim)
        btnMCQ?.startAnimation(slideUpAnim)

        // Camera Test
        btnCamera.setOnClickListener {
            startActivity(Intent(this, CameraTestActivity::class.java))
        }

        // MCQ Test
        btnMCQ.setOnClickListener {
            startActivity(Intent(this, MCQTestActivity::class.java))
        }
    }
}