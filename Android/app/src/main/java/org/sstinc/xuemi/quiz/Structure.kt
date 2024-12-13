package org.sstinc.xuemi.quiz

import android.content.Context
import android.util.Log
import com.google.gson.Gson
import java.io.IOException

data class Word (
    var index: Int,
    var word: String,
    var pinyin: String,
    var englishDefinition: String,
    var chineseDefinition: String,
    var q1: String,
    var q2: String
)

data class CombinedWord(
    val name: String,
    val topic: List<Word> = emptyList()
)
data class Topic(
    val topic1: CombinedWord,
    val topic2: CombinedWord,
    val topic3: CombinedWord
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
            json = String(buffer, Charsets.UTF_8)


        } catch (e: IOException) {
            e.printStackTrace()
            Log.e("temp", "Error reading or parsing JSON file: $fileName", e)

            return null
        }

        return Gson().fromJson(json, Secondary::class.java)
    }
}