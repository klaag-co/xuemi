package org.sstinc.xuemi.db

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverter
import androidx.room.TypeConverters
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import org.sstinc.xuemi.quiz.Word

@Database(entities = [Afolder::class], version = 1)
@TypeConverters(ConvertersFOLDERS::class)
abstract class FoldersDatabase: RoomDatabase() {
    companion object {
        const val NAME = "Folders_DB"
    }
    abstract fun getFoldersDao(): FoldersDao
}

class ConvertersFOLDERS {
    @TypeConverter
    fun fromWordList(words: List<Word>): String {
        return Gson().toJson(words)
    }

    @TypeConverter
    fun toWordList(words: String): List<Word> {
        val listType = object: TypeToken<List<Word>>() {}.type
        return Gson().fromJson(words, listType)
    }
}