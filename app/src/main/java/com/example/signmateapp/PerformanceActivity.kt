package com.example.signmateapp

import android.os.Bundle
import android.widget.ProgressBar
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import java.text.SimpleDateFormat
import java.util.*

import com.github.mikephil.charting.charts.LineChart
import com.github.mikephil.charting.data.*
import com.github.mikephil.charting.components.XAxis
import com.github.mikephil.charting.formatter.IndexAxisValueFormatter

class PerformanceActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_performance)

        val sharedPref = getSharedPreferences("SignMateData", MODE_PRIVATE)
        val data = sharedPref.getString("scores", "") ?: ""

        val avgText = findViewById<TextView>(R.id.avgScoreText)
        val lineChart = findViewById<LineChart>(R.id.lineChart)

        if (data.isEmpty()) {
            avgText.text = "No data available"
            return
        }

        // Parse stored data
        val entriesList = data.split(",").map {
            val parts = it.split(":")
            val date = parts[0]
            val score = parts[1].toInt()
            Pair(date, score)
        }

        // Last 7 days
        val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        val calendar = Calendar.getInstance()

        val last7Days = mutableListOf<String>()
        for (i in 6 downTo 0) {
            calendar.time = Date()
            calendar.add(Calendar.DAY_OF_YEAR, -i)
            last7Days.add(sdf.format(calendar.time))
        }

        // Map date → scores
        val dailyScores = mutableMapOf<String, MutableList<Int>>()

        for ((date, score) in entriesList) {
            if (date in last7Days) {
                if (!dailyScores.containsKey(date)) {
                    dailyScores[date] = mutableListOf()
                }
                dailyScores[date]?.add(score)
            }
        }

        // Progress Bars
        val bars = listOf(
            R.id.day1, R.id.day2, R.id.day3,
            R.id.day4, R.id.day5, R.id.day6, R.id.day7
        )

        var total = 0
        var count = 0

        val chartEntries = ArrayList<Entry>()
        val labels = ArrayList<String>()

        for (i in last7Days.indices) {

            val date = last7Days[i]
            val scores = dailyScores[date]

            val progressBar = findViewById<ProgressBar>(bars[i])

            val value = if (scores != null && scores.isNotEmpty()) {
                val avg = scores.average().toInt()
                progressBar.progress = avg * 10

                total += avg
                count++

                avg.toFloat()
            } else {
                progressBar.progress = 0
                0f
            }

            chartEntries.add(Entry(i.toFloat(), value))

            // Convert to day label (Mon, Tue...)
            val dayFormat = SimpleDateFormat("EEE", Locale.getDefault())
            val parsedDate = sdf.parse(date)
            labels.add(dayFormat.format(parsedDate!!))
        }

        val avg = if (count > 0) total / count else 0
        avgText.text = "Weekly Avg: $avg%"

        // 🔥 CHART SETUP
        val dataSet = LineDataSet(chartEntries, "Performance")
        dataSet.lineWidth = 3f
        dataSet.circleRadius = 5f
        dataSet.valueTextSize = 12f

        val lineData = LineData(dataSet)
        lineChart.data = lineData

        val xAxis = lineChart.xAxis
        xAxis.position = XAxis.XAxisPosition.BOTTOM
        xAxis.granularity = 1f
        xAxis.valueFormatter = IndexAxisValueFormatter(labels)

        lineChart.axisRight.isEnabled = false
        lineChart.description.isEnabled = false
        lineChart.animateY(1000)

        lineChart.invalidate()
    }
}