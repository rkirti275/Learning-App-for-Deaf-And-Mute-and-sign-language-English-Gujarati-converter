package com.example.signmateapp

import android.os.Bundle
import android.view.GestureDetector
import android.view.MotionEvent
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

class AlphabetDetailActivity : AppCompatActivity() {

    private lateinit var gestureDetector: GestureDetector
    private lateinit var letter: String

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_alphabet_detail)

        val imageView = findViewById<ImageView>(R.id.detailImage)
        val textView = findViewById<TextView>(R.id.detailText)

        letter = intent.getStringExtra("letter") ?: "A"
        textView.text = letter

        loadImage(letter, imageView)

        // Gesture Detector
        gestureDetector = GestureDetector(this, object : GestureDetector.SimpleOnGestureListener() {

            override fun onFling(
                e1: MotionEvent?,
                e2: MotionEvent,
                velocityX: Float,
                velocityY: Float
            ): Boolean {

                val diffX = e2.x - (e1?.x ?: 0f)

                if (diffX > 100) {
                    // 👉 Swipe Right (Previous)
                    moveToPrevious()
                } else if (diffX < -100) {
                    // 👉 Swipe Left (Next)
                    moveToNext()
                }

                return true
            }
        })
    }

    private fun loadImage(letter: String, imageView: ImageView) {
        val path = "images/alphabets/${letter.lowercase()}.png"
        val inputStream = assets.open(path)
        val drawable = android.graphics.drawable.Drawable.createFromStream(inputStream, null)
        imageView.setImageDrawable(drawable)
    }

    private fun moveToNext() {
        if (letter[0] < 'Z') {
            val next = (letter[0] + 1).toString()
            restartActivity(next)
        }
    }

    private fun moveToPrevious() {
        if (letter[0] > 'A') {
            val prev = (letter[0] - 1).toString()
            restartActivity(prev)
        }
    }

    private fun restartActivity(newLetter: String) {
        val intent = intent
        intent.putExtra("letter", newLetter)
        finish()
        startActivity(intent)
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        return gestureDetector.onTouchEvent(event) || super.onTouchEvent(event)
    }
}