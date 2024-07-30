package com.example.xuemi.db

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverter
import androidx.room.TypeConverters
import com.example.xuemi.quiz.MCQquestion
import com.example.xuemi.quiz.MCQtopic
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken


@Database(entities = [MCQtopic::class], version = 1)
@TypeConverters(Converters::class)
abstract class MCQDatabase: RoomDatabase() {
    companion object {
        const val NAME = "MCQ_DB"
    }
    abstract fun getMCQDao () : MCQDao
}
class Converters {
    @TypeConverter
    fun fromMCQquestionList(value: List<MCQquestion>): String {
        val gson = Gson()
        val type = object : TypeToken<List<MCQquestion>>() {}.type
        return gson.toJson(value, type)
    }

    @TypeConverter
    fun toMCQquestionList(value: String): List<MCQquestion> {
        val gson = Gson()
        val type = object : TypeToken<List<MCQquestion>>() {}.type
        return gson.fromJson(value, type)
    }
}