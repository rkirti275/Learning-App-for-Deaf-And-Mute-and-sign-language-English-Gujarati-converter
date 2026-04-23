package com.example.signmateapp

import android.os.Bundle
import android.widget.GridView
import androidx.appcompat.app.AppCompatActivity

class LearningActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_learning)

        val gridView = findViewById<GridView>(R.id.gridView)

        val letters = ('A'..'Z').toList()

        val adapter = AlphabetAdapter(this, letters)
        gridView.adapter = adapter
    }
}