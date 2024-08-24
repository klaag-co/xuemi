package org.sstinc.xuemi.db

import androidx.lifecycle.LiveData
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import org.sstinc.xuemi.Note
import org.sstinc.xuemi.NoteType


@Dao
interface NotesDao {
    @Query("SELECT * FROM NOTE")
    fun getAllNotes(): List<Note>

    @Insert
    fun addNote(note: Note)

    @Query("Delete FROM Note where id=:id")
    fun deleteNote(id: Int)

    @Query("UPDATE NOTE set title = :title, body = :body where id=:id")
    fun updateNote(title: String, body: String, id: Int)


    @Query("SELECT * FROM Note WHERE title LIKE '%' || :searchText || '%' AND type = :type")
    fun searchNotesByTitle(searchText: String, type: NoteType): LiveData<List<Note>>
}

