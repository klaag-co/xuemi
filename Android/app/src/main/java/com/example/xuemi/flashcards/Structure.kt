package com.example.xuemi.flashcards

import android.content.Context
import com.google.gson.Gson
import java.io.IOException
import java.nio.charset.Charset

data class Word (
    var index: Int,
    var word: String,
    var pinyin: String,
    var englishDefinition: String,
    var chineseDefinition: String,
    var example: String
)
data class Topic(
    val topic1: List<Word> = emptyList(),
    val topic2: List<Word> = emptyList(),
    val topic3: List<Word> = emptyList()
)

data class Chapter(
    val name: String,
    val topics: Topic
)

data class Secondary(
    val chapters: List<Chapter>
)

class JsonReader(private val context: Context) {
    fun readJsonFile(fileName: String): Secondary? {
        val json: String?
        try {
            val inputStream = context.assets.open(fileName)
            val size = inputStream.available()
            val buffer = ByteArray(size)
            inputStream.read(buffer)
            inputStream.close()
            json = String(buffer, Charset.defaultCharset())

        } catch (e: IOException) {
            e.printStackTrace()
            return null
        }

        return Gson().fromJson(json, Secondary::class.java)
    }
}