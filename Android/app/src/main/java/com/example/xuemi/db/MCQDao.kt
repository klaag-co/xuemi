package com.example.xuemi.db

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Transaction
import com.example.xuemi.flashcards.MCQquestion
import com.example.xuemi.flashcards.MCQtopic


@Dao
interface MCQDao {
    @Query("SELECT * FROM MCQtopic")
    fun getAllQuestions(): List<MCQtopic>

    @Insert
    fun addTopic(topic: MCQtopic)

    @Query("DELETE FROM MCQtopic WHERE id=:id")
    fun deleteTopic(id: Int)

    @Query("DELETE FROM MCQtopic")
    fun deleteAll()

    @Query("UPDATE MCQtopic SET questions=:questions WHERE id=:id")
    fun updateQuestions(questions: List<MCQquestion>, id: Int)

    @Query("SELECT * FROM MCQtopic WHERE id = :topicId")
    fun getTopicById(topicId: Int): MCQtopic?

    @Query("SELECT * FROM MCQtopic WHERE topic = :topicName")
    fun getTopicByName(topicName: String): MCQtopic?

    @Query("SELECT COUNT(*) FROM MCQtopic WHERE topic = :topic")
    suspend fun topicExists(topic: String): Int

    @Query("UPDATE MCQtopic SET leftOff = :leftOff WHERE id = :id")
    fun updateLeftOff(leftOff: Int, id: Int)


    @Transaction
    fun updateSelectedQuestion(topicId: Int, questionIndex: Int, newSelected: String) {
        val topic = getTopicById(topicId)
        topic?.let {
            val updatedQuestions = it.questions.toMutableList().apply {
                this[questionIndex] = this[questionIndex].copy(selected = newSelected)
            }
            updateQuestions(updatedQuestions, topicId)
        }
    }

}