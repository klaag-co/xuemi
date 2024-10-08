package org.sstinc.xuemi.db


import androidx.room.Database
import androidx.room.RoomDatabase
import org.sstinc.xuemi.Note

@Database(entities = [Note::class], version = 1)
abstract class NotesDatabase: RoomDatabase() {
    companion object {
        const val NAME = "Notes_DB"
    }
    abstract fun getNotesDao () : NotesDao
}