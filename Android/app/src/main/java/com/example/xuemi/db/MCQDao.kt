package com.example.xuemi.db

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import com.example.xuemi.Note
import com.example.xuemi.flashcards.MCQ

@Dao
interface MCQDao {
    @Query("SELECT * FROM MCQ")
    fun getAllQuestions(): List<MCQ>

    @Insert
    fun addQuestion(note: MCQ)

    @Query("Delete FROM Note where id=:id")
    fun deleteNote(id: Int)

    @Query("UPDATE NOTE set title = :title, body = :body where id=:id")
    fun updateNote(title: String, body: String, id: Int)
}