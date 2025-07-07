package org.sstinc.xuemi.db

import androidx.room.Dao
import androidx.room.Entity
import androidx.room.Insert
import androidx.room.PrimaryKey
import androidx.room.Query
import kotlinx.coroutines.flow.Flow
import org.sstinc.xuemi.quiz.Word

@Entity
data class Afolder(
    @PrimaryKey(autoGenerate = true)
    val id: Int = 0,
    val name: String,
    val items: List<Word>
)
@Dao
interface FoldersDao {
    @Query("SELECT * FROM AFOLDER")
    fun getAllFolders(): Flow<List<Afolder>>

    @Insert
    fun addFolder(folder: Afolder)

    @Query("DELETE FROM Afolder")
    fun deleteAll()

    @Query("DELETE FROM Afolder WHERE id=:id")
    fun deleteFolder(id: Int)

    @Query("SELECT * FROM Afolder WHERE id = :folderID")
    fun getFolderByID(folderID: Int): Afolder?

}