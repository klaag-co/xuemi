package org.sstinc.xuemi.db

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import org.sstinc.xuemi.Afolder

@Dao
interface FoldersDao {
    @Query("SELECT * FROM AFOLDER")
    fun getAllFolders(): List<Afolder>

    @Insert
    suspend fun addFolder(folder: Afolder)

    @Query("DELETE FROM Afolder WHERE id=:id")
    fun deleteFolder(id: Int)

    @Query("SELECT * FROM Afolder WHERE id = :folderID")
    fun getFolderByID(folderID: Int): Afolder?

}