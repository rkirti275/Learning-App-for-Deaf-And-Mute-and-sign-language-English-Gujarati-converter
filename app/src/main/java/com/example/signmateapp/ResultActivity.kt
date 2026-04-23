package com.example.signmateapp

import android.content.Intent
import android.os.Bundle
import android.widget.*
import androidx.appcompat.app.AppCompatActivity

class ResultActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_result)

        val scoreText = findViewById<TextView>(R.id.scoreText)
        val percentageText = findViewById<TextView>(R.id.percentageText)
        val performanceText = findViewById<TextView>(R.id.performanceText)
        val btnRestart = findViewById<Button>(R.id.btnRestart)
        val btnHome = findViewById<Button>(R.id.btnHome)

        // Get data from intent
        val score = intent.getIntExtra("score", 0)
        val total = intent.getIntExtra("total", 10)

        val percentage = (score * 100) / total

        // Set texts
        scoreText.text = "$score / $total"
        percentageText.text = "$percentage%"

        // Performance message
        performanceText.text = when {
            percentage >= 80 -> "🔥 Excellent!"
            percentage >= 50 -> "👍 Good Job!"
            else -> "💡 Keep Practicing!"
        }

        // Restart quiz
        btnRestart.setOnClickListener {
            startActivity(Intent(this, MCQTestActivity::class.java))
            finish()
        }

        // Go to home
        btnHome.setOnClickListener {
            startActivity(Intent(this, MainActivity::class.java))
            finish()
        }

        // Load animations
        val bounceAnim = android.view.animation.AnimationUtils.loadAnimation(this, R.anim.bounce)
        val slideUpAnim = android.view.animation.AnimationUtils.loadAnimation(this, R.anim.slide_up)

        // Apply animations
        scoreText.startAnimation(bounceAnim)
        performanceText.startAnimation(bounceAnim)
        btnRestart.startAnimation(slideUpAnim)
        btnHome.startAnimation(slideUpAnim)
    }
}