package com.example.xuemi.db

import androidx.room.Database
import androidx.room.RoomDatabase
import com.example.xuemi.Bookmark

@Database(entities = [Bookmark::class], version = 1)
abstract class BookmarksDatabase: RoomDatabase() {
    companion object {
        const val NAME = "Bookmarks_DB"
    }
    abstract fun getBookmarksDao () : BookmarksDao
}