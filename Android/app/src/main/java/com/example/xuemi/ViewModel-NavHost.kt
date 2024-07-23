package com.example.xuemi

import android.annotation.SuppressLint
import android.app.Application
import android.content.Context
import android.content.SharedPreferences
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.room.Room
import com.example.xuemi.db.BookmarksDatabase
import com.example.xuemi.db.BookmarksRepository
import com.example.xuemi.db.NotesDatabase
import com.example.xuemi.flashcards.Chapter
import com.example.xuemi.flashcards.FlashcardScreen
import com.example.xuemi.flashcards.JsonReader
import com.example.xuemi.flashcards.MCQ
import com.example.xuemi.flashcards.Secondary
import com.google.gson.Gson
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class MainApplication: Application() {
    companion object {
        lateinit var notesDatabase: NotesDatabase
        lateinit var bookmarksDatabase: BookmarksDatabase
    }

    override fun onCreate() {
        super.onCreate()
        notesDatabase = Room.databaseBuilder(
            applicationContext,
            NotesDatabase::class.java,
            NotesDatabase.NAME
        ).build()
        bookmarksDatabase = Room.databaseBuilder(
            applicationContext,
            BookmarksDatabase::class.java,
            BookmarksDatabase.NAME
        ).build()
    }
}



class MyViewModel( appContext: Context, application: Application ) : AndroidViewModel(application) {
    private val sharedPreferences: SharedPreferences = application.getSharedPreferences("my_prefs", Context.MODE_PRIVATE)
    private val gson = Gson()
    private val _current: MutableStateFlow<List<String>> = MutableStateFlow(loadListFromPreferences())
    val current: StateFlow<List<String>> get() = _current.asStateFlow()

    private fun loadListFromPreferences(): List<String> {
        val defaultList = listOf("S", "C", "C.", "T", "Q", "W.")
        val listString = sharedPreferences.getString("current_list", null) ?: return defaultList
        return listString.split(",").map { it.trim() }
    }

    private fun saveListToPreferences(list: List<String>) {
        val listString = list.joinToString(",")
        sharedPreferences.edit().putString("current_list", listString).apply()
    }

    fun updateItem(index: Int, newItem: String) {
        val currentList = _current.value.toMutableList()
        if (index in currentList.indices) {
            currentList[index] = newItem
            _current.value = currentList
            saveListToPreferences(currentList)
        }
    }

    fun getFromList(index: Int): String {
        return _current.value.getOrElse(index) { "" }
    }

//============================================================//

    private val _showButton = MutableStateFlow(true)
    val showButton: StateFlow<Boolean> = _showButton

    fun offButton() {
        _showButton.value = false
    }

    fun onButton() {
        _showButton.value = true
    }

//============================================================//

    val notesDao = MainApplication.notesDatabase.getNotesDao()
    private val _notesList = MutableLiveData<List<Note>>()
    val notesList: LiveData<List<Note>> get() = _notesList

    init {
        loadNotes()
    }
    private fun loadNotes() {
        viewModelScope.launch(Dispatchers.IO) {
            val notes = notesDao.getAllNotes()
            _notesList.postValue(notes)
        }
    }


    fun add(type: NoteType, title: String, body: String) {
        viewModelScope.launch (Dispatchers.IO) {
            notesDao.addNote(Note(type = type, title = title, body = body))
            loadNotes()
        }
    }
    fun delete(id: Int) {
        viewModelScope.launch(Dispatchers.IO) {
            notesDao.deleteNote(id)
            loadNotes()
        }
    }

    fun update(title: String, body: String, id: Int){
        viewModelScope.launch(Dispatchers.IO) {
            notesDao.updateNote(title, body, id)
            loadNotes()
        }
    }



    fun searchNotesByTitle(searchText: String, type: NoteType): LiveData<List<Note>> {
        return notesDao.searchNotesByTitle(searchText, type)
    }

//============================================================//

    val bookmarksDao = MainApplication.bookmarksDatabase.getBookmarksDao()
    private val _bookmarksList = MutableLiveData<List<Bookmark>>()
    val bookmarksList: LiveData<List<Bookmark>> get() = _bookmarksList
    private val repository: BookmarksRepository

    init {
        repository = BookmarksRepository(bookmarksDao)
        loadBookmarks()
        loadBookmarkNames()
    }


    fun loadBookmarks() {
        viewModelScope.launch(Dispatchers.IO) {
            val bookmarks = bookmarksDao.getAllBookmarks()
            _bookmarksList.postValue(bookmarks)
        }
    }

    fun deleteBookmark(id: Int) {
        viewModelScope.launch(Dispatchers.IO) {
            bookmarksDao.deleteBookmark(id)
            loadBookmarks()
            loadBookmarkNames()

        }
    }


    fun addBookmark(section: BookmarkSection, word: String, chapter: String, topic: String) {
        viewModelScope.launch(Dispatchers.IO) {
            bookmarksDao.addBookmark(
                Bookmark(
                    type = section,
                    word = word,
                    chapter = chapter,
                    topic = topic
                )
            )
            loadBookmarks()
            loadBookmarkNames()
        }
    }



    private val _bookmarkWords = MutableLiveData<List<String>>()
    val bookmarkWords: LiveData<List<String>> get() = _bookmarkWords

    fun loadBookmarkNames() {
        viewModelScope.launch(Dispatchers.IO) {
            val words = repository.getBookmarkWords()
            _bookmarkWords.postValue(words)
            loadBookmarks()
            loadBookmarkNames()
        }
    }


    fun searchBookmarksByTitle(searchText: String, type: BookmarkSection): LiveData<List<Bookmark>> {
        return bookmarksDao.searchBookmarksByTitle(searchText, type)
    }

//============================================================//

    private val jsonReader = JsonReader(appContext)

    fun loadDataFromJson(name: String): Secondary? {
        return jsonReader.readJsonFile(name)
    }
}

@SuppressLint("UnusedMaterial3ScaffoldPaddingParameter")
@Composable
fun HomeNav(viewModel: MyViewModel) {
    val navController = rememberNavController()
    val homeTab = TabBarItem(
        title = "Home",
        selectedIcon = R.drawable.home,
        unselectedIcon = R.drawable.o_home
    )
    val bookmarkTab = TabBarItem(
        title = "Bookmarks",
        selectedIcon = R.drawable.bookmark,
        unselectedIcon = R.drawable.o_bookmark
    )
    val notesTab = TabBarItem(
        title = "Notes",
        selectedIcon = R.drawable.notes,
        unselectedIcon = R.drawable.o_notes
    )
    val settingsTab = TabBarItem(
        title = "Settings",
        selectedIcon = R.drawable.settings,
        unselectedIcon = R.drawable.o_settings
    )

    val tabBarItems = listOf(homeTab, bookmarkTab, notesTab, settingsTab)

    Scaffold(bottomBar = { TabView(tabBarItems, navController) }) {

        NavHost(navController, startDestination = homeTab.title) {
            // tabs
            composable(homeTab.title) { Home(viewModel, navController) }
            composable(bookmarkTab.title) { Bookmarks(viewModel) }
            composable(notesTab.title) { Notes(viewModel, navController) }
            composable(settingsTab.title) { Settings() }

            // navigation
            composable("secondary") { Secondary(viewModel, navController) }
            composable("chapter") { Chapter(viewModel, navController) }
            composable("notes") { Notes(viewModel, navController) }
            composable("addnote") { CreateNote(viewModel, navController) }
            composable("update/{itemId}") { backStackEntry ->
                val itemId = backStackEntry.arguments?.getString("itemId")?.toIntOrNull()
                UpdateNote(navController, viewModel, itemID = itemId)
            }
            composable("flashcards") { FlashcardScreen(viewModel, navController) }
            composable("mcq"){ MCQ(viewModel, navController) }

        }
    }

}