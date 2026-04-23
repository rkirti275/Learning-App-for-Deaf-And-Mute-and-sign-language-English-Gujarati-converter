package com.example.signmateapp

import android.content.Context
import android.content.Intent
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import android.widget.ImageView
import android.widget.TextView

class AlphabetAdapter(
    private val context: Context,
    private val letters: List<Char>
) : BaseAdapter() {

    override fun getCount(): Int = letters.size

    override fun getItem(position: Int): Any = letters[position]

    override fun getItemId(position: Int): Long = position.toLong()

    override fun getView(position: Int, convertView: View?, parent: ViewGroup?): View {

        val view = LayoutInflater.from(context)
            .inflate(R.layout.item_alphabet, parent, false)

        val image = view.findViewById<ImageView>(R.id.imageView)
        val text = view.findViewById<TextView>(R.id.textView)

        val letter = letters[position]
        text.text = letter.toString()

        // Load image from assets
        val imageName = letter.lowercase()
        val assetPath = "images/alphabets/$imageName.png"

        try {
            val inputStream = context.assets.open(assetPath)
            val drawable = android.graphics.drawable.Drawable.createFromStream(inputStream, null)
            image.setImageDrawable(drawable)
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // ✅ CLICK FUNCTION (NEW FEATURE)
        view.setOnClickListener {
            val intent = Intent(context, AlphabetDetailActivity::class.java)
            intent.putExtra("letter", letter.toString())
            context.startActivity(intent)
        }

        return view
    }
}