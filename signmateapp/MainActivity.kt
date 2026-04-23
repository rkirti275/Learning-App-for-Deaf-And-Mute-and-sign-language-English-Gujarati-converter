package com.example.signmateapp

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.app.AppCompatDelegate
import com.google.android.material.switchmaterial.SwitchMaterial

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Load Theme preference before inflating view
        val sharedPref = getSharedPreferences("SignMateData", MODE_PRIVATE)
        val isDarkMode = sharedPref.getBoolean("isDarkMode", false)
        if (isDarkMode) {
            AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES)
        } else {
            AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO)
        }

        setContentView(R.layout.activity_main)

        val btnLearn = findViewById<Button>(R.id.btnLearn)
        val btnTest = findViewById<Button>(R.id.btnTest)
        val btnPerformance = findViewById<Button>(R.id.btnPerformance)
        val streakText = findViewById<TextView>(R.id.streakText)
        val switchTheme = findViewById<SwitchMaterial>(R.id.switchTheme)
        
        // Setup Views for Animations
        val tvTitle = findViewById<TextView>(R.id.tvTitle)
        val buttonContainer = findViewById<android.widget.LinearLayout>(R.id.buttonContainer)
        
        // Load Animations
        val bounceAnim = android.view.animation.AnimationUtils.loadAnimation(this, R.anim.bounce)
        val slideUpAnim = android.view.animation.AnimationUtils.loadAnimation(this, R.anim.slide_up)

        // Apply Animations
        tvTitle?.startAnimation(bounceAnim)
        streakText?.startAnimation(bounceAnim)
        buttonContainer?.startAnimation(slideUpAnim)

        // Set initial switch state
        switchTheme.isChecked = isDarkMode

        // Theme Toggle Handler
        switchTheme.setOnCheckedChangeListener { _, isChecked ->
            sharedPref.edit().putBoolean("isDarkMode", isChecked).apply()
            if (isChecked) {
                AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES)
            } else {
                AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO)
            }
        }

        // Load streak safely
        val streak = sharedPref.getInt("streak", 0)
        streakText.text = "🔥 Streak: $streak days"

        // Learn button
        btnLearn.setOnClickListener {
            startActivity(Intent(this, LearningActivity::class.java))
        }

        // Test button
        btnTest.setOnClickListener {
            startActivity(Intent(this, TestActivity::class.java))
        }

        // Performance button
        if (btnPerformance != null) {
            btnPerformance.setOnClickListener {
                startActivity(Intent(this, PerformanceActivity::class.java))
            }
        }
    }

    override fun onResume() {
        super.onResume()

        // Refresh streak every time user returns to Home
        val sharedPref = getSharedPreferences("SignMateData", MODE_PRIVATE)
        val streak = sharedPref.getInt("streak", 0)

        val streakText = findViewById<TextView>(R.id.streakText)
        streakText.text = "🔥 Streak: $streak days"
    }
}