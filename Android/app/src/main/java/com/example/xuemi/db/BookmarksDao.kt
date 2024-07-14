package com.example.xuemi.db

import androidx.lifecycle.LiveData
import androidx.room.ColumnInfo
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import com.example.xuemi.Bookmark
import com.example.xuemi.BookmarkSection

data class BookmarkWord(
    @ColumnInfo(name = "word") val word: String
)
@Dao
interface BookmarksDao {
    @Query("SELECT * FROM BOOKMARK")
    fun getAllBookmarks(): List<Bookmark>

    @Insert
    fun addBookmark(bookmark: Bookmark)

    @Query("DELETE FROM BOOKMARK where id=:id")
    fun deleteBookmark(id: Int)
    @Query("SELECT word FROM Bookmark")
    fun loadWords(): List<BookmarkWord>

    @Query("SELECT * FROM Bookmark WHERE word LIKE '%' || :searchText  || '%' AND type = :type")
    fun searchBookmarksByTitle(searchText: String, type: BookmarkSection): LiveData<List<Bookmark>>


}

class BookmarksRepository(private val bookmarksDao: BookmarksDao) {
    fun getBookmarkWords(): List<String> {
        return bookmarksDao.loadWords().map { it.word }
    }
}