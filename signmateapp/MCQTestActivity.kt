package com.example.signmateapp

import android.content.Intent
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.os.CountDownTimer
import android.os.Handler
import android.os.Looper
import android.widget.*
import androidx.appcompat.app.AppCompatActivity

class MCQTestActivity : AppCompatActivity() {

    private var score = 0
    private var currentQuestion = 0

    private lateinit var questions: List<MCQQuestion>
    private lateinit var countDownTimer: CountDownTimer

    private val timePerQuestion: Long = 30000

    private var selectedAnswer: String? = null
    private var isAnswered = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_mcq_test)

        questions = generateRandomQuestions()
        loadQuestion()

        val btnNext = findViewById<Button>(R.id.btnNext)

        btnNext.setOnClickListener {

            if (isAnswered) return@setOnClickListener

            if (selectedAnswer == null) {
                Toast.makeText(this, "Please select an answer", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }

            countDownTimer.cancel()
            isAnswered = true

            val correctAnswer = questions[currentQuestion].correctAnswer

            val optionsContainer = findViewById<LinearLayout>(R.id.optionsContainer)

            // Show correct/wrong colors
            for (i in 0 until optionsContainer.childCount) {
                val optionView = optionsContainer.getChildAt(i) as TextView
                val text = optionView.text.toString()

                when {
                    text == correctAnswer -> {
                        optionView.setBackgroundResource(R.drawable.correct_option_bg)
                    }
                    text == selectedAnswer -> {
                        optionView.setBackgroundResource(R.drawable.wrong_option_bg)
                    }
                }
            }

            if (selectedAnswer == correctAnswer) {
                score++
            }

            // Delay before next question
            Handler(Looper.getMainLooper()).postDelayed({
                currentQuestion++

                if (currentQuestion < questions.size) {
                    loadQuestion()
                } else {
                    goToResult()
                }
            }, 1500)
        }
    }

    private fun generateRandomQuestions(): List<MCQQuestion> {

        val alphabets = ('A'..'Z').map { it.toString() }.toMutableList()
        alphabets.shuffle()

        val selected = alphabets.take(10)

        val questionList = mutableListOf<MCQQuestion>()

        for (letter in selected) {

            val options = mutableSetOf<String>()
            options.add(letter)

            while (options.size < 4) {
                val randomLetter = ('A'..'Z').random().toString()
                options.add(randomLetter)
            }

            val finalOptions = options.shuffled()

            questionList.add(
                MCQQuestion(
                    imageName = letter.lowercase() + ".png",
                    correctAnswer = letter,
                    options = finalOptions
                )
            )
        }

        return questionList
    }

    private fun loadQuestion() {

        val questionText = findViewById<TextView>(R.id.questionText)
        val imageView = findViewById<ImageView>(R.id.questionImage)
        val progressText = findViewById<TextView>(R.id.progressText)
        val optionsContainer = findViewById<LinearLayout>(R.id.optionsContainer)

        val currentQ = questions[currentQuestion]

        isAnswered = false
        selectedAnswer = null

        progressText.text = "Question ${currentQuestion + 1} / ${questions.size}"
        questionText.text = "Identify this Sign"
        
        val progressBar = findViewById<ProgressBar>(R.id.progressBar)
        if (questions.isNotEmpty()) {
            progressBar.max = questions.size
            progressBar.progress = currentQuestion + 1
        }

        try {
            val inputStream = assets.open("images/alphabets/${currentQ.imageName}")
            val drawable = Drawable.createFromStream(inputStream, null)
            imageView.setImageDrawable(drawable)
        } catch (e: Exception) {
            e.printStackTrace()
        }

        optionsContainer.removeAllViews()

        for (option in currentQ.options) {

            val optionView = TextView(this)
            optionView.text = option
            optionView.textSize = 18f
            optionView.setPadding(30, 30, 30, 30)
            optionView.setBackgroundResource(R.drawable.option_bg)

            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, 0, 0, 20)
            optionView.layoutParams = params

            optionView.setOnClickListener {

                if (isAnswered) return@setOnClickListener

                // Reset all
                for (i in 0 until optionsContainer.childCount) {
                    optionsContainer.getChildAt(i)
                        .setBackgroundResource(R.drawable.option_bg)
                }

                // Select
                optionView.setBackgroundResource(R.drawable.selected_option_bg)
                selectedAnswer = option
            }

            optionsContainer.addView(optionView)
        }

        // Apply Animations dynamically
        val slideUpAnim = android.view.animation.AnimationUtils.loadAnimation(this, R.anim.slide_up)
        val bounceAnim = android.view.animation.AnimationUtils.loadAnimation(this, R.anim.bounce)
        
        imageView.startAnimation(bounceAnim)
        questionText.startAnimation(bounceAnim)
        optionsContainer.startAnimation(slideUpAnim)

        startTimer()
    }

    private fun startTimer() {

        val timerText = findViewById<TextView>(R.id.timerText)

        countDownTimer = object : CountDownTimer(timePerQuestion, 1000) {

            override fun onTick(millisUntilFinished: Long) {
                val seconds = millisUntilFinished / 1000
                timerText.text = "${seconds}s"
            }

            override fun onFinish() {

                currentQuestion++

                if (currentQuestion < questions.size) {
                    loadQuestion()
                } else {
                    goToResult()
                }
            }
        }.start()
    }

    private fun goToResult() {

        saveScore(score)
        updateStreak()

        val intent = Intent(this, ResultActivity::class.java)
        intent.putExtra("score", score)
        intent.putExtra("total", questions.size)
        startActivity(intent)
        finish()
    }
    private fun saveScore(score: Int) {

        val sharedPref = getSharedPreferences("SignMateData", MODE_PRIVATE)
        val editor = sharedPref.edit()

        val existingData = sharedPref.getString("scores", "") ?: ""

        // Get current date
        val date = java.text.SimpleDateFormat("yyyy-MM-dd").format(java.util.Date())

        val newEntry = "$date:$score"

        val newData = if (existingData.isEmpty()) {
            newEntry
        } else {
            "$existingData,$newEntry"
        }

        editor.putString("scores", newData)
        editor.apply()
    }

    private fun updateStreak() {

        val sharedPref = getSharedPreferences("SignMateData", MODE_PRIVATE)
        val editor = sharedPref.edit()

        val sdf = java.text.SimpleDateFormat("yyyy-MM-dd")
        val today = sdf.format(java.util.Date())

        val lastDate = sharedPref.getString("last_date", null)
        var streak = sharedPref.getInt("streak", 0)

        if (lastDate == null) {
            // First time
            streak = 1
        } else {

            val dateFormat = java.text.SimpleDateFormat("yyyy-MM-dd")
            val last = dateFormat.parse(lastDate)
            val current = dateFormat.parse(today)

            val diff = (current.time - last.time) / (1000 * 60 * 60 * 24)

            when (diff) {
                0L -> {
                    // Same day → no change
                }
                1L -> {
                    streak += 1
                }
                else -> {
                    streak = 1
                }
            }
        }

        editor.putString("last_date", today)
        editor.putInt("streak", streak)
        editor.apply()
    }

    override fun onDestroy() {
        super.onDestroy()
        if (::countDownTimer.isInitialized) {
            countDownTimer.cancel()
        }
    }
}