package org.sstinc.xuemi.db

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import org.sstinc.xuemi.Bookmark

@Database(entities = [Bookmark::class], version = 2)
abstract class BookmarksDatabase: RoomDatabase() {
    companion object {
        const val NAME = "Bookmarks_DB"
    }
    abstract fun getBookmarksDao () : BookmarksDao
}
val MIGRATION_1_2 = object : Migration(1, 2) {
    override fun migrate(db: SupportSQLiteDatabase) {
        val columns = db.query("PRAGMA table_info")
        var columnExists = false

        while (columns.moveToNext()) {
            val name = columns.getString(columns.getColumnIndexOrThrow("name"))
            if (name == "leftOff") {
                columnExists = true
                break
            }
        }

        columns.close()

        if (!columnExists) {
            db.execSQL("ALTER TABLE Bookmark ADD COLUMN leftOff INTEGER NOT NULL DEFAULT 0")
        }
    }
}