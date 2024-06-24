package com.example.xuemi.db

import androidx.lifecycle.LiveData
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import com.example.xuemi.Note

@Dao
interface NotesDao {
    @Query("SELECT * FROM NOTE")
    fun getAllNotes() : LiveData<List<Note>>

    @Insert
    fun addNote(note: Note)

    @Query("Delete FROM Note where id=:id")
    fun deleteNote(id: Int)

//    fun updatenote(id: Int)
}

