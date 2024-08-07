package com.example.xuemi

import android.annotation.SuppressLint
import android.app.Application
import android.content.Context
import android.content.SharedPreferences
import android.util.Log
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
import com.example.xuemi.db.MCQDatabase
import com.example.xuemi.db.NotesDatabase
import com.example.xuemi.quiz.Chapter
import com.example.xuemi.quiz.FlashcardScreen
import com.example.xuemi.quiz.JsonReader
import com.example.xuemi.quiz.MCQ
import com.example.xuemi.quiz.MCQquestion
import com.example.xuemi.quiz.MCQresults
import com.example.xuemi.quiz.MCQtopic
import com.example.xuemi.quiz.Secondary
import com.example.xuemi.quiz.Word
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class MainApplication: Application() {
    companion object {
        lateinit var notesDatabase: NotesDatabase
        lateinit var bookmarksDatabase: BookmarksDatabase
        lateinit var mcqDatabase: MCQDatabase
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
        mcqDatabase = Room.databaseBuilder(
            applicationContext,
            MCQDatabase::class.java,
            MCQDatabase.NAME
        ).build()
    }
}



class MyViewModel( appContext: Context, application: Application ) : AndroidViewModel(application) {
    private val sharedPreferences: SharedPreferences =
        application.getSharedPreferences("my_prefs", Context.MODE_PRIVATE)
    private val _default: MutableStateFlow<List<String>> =
        MutableStateFlow(loadListFromPreferences())
    val _current = MutableStateFlow(listOf("S", "C", "C.", "T", "Q", "W."))

    private val _words = MutableLiveData<List<Word>>()

    val words: MutableLiveData<List<Word>> = _words

    init {
        loadListFromPreferences()
        complete()
    }

    //============================================================//


    private val jsonReader = JsonReader(appContext)

    fun loadDataFromJson(name: String): Secondary? {
        return jsonReader.readJsonFile(name)
    }

    private fun loadListFromPreferences(): List<String> {
        val defaultList = listOf("S", "C", "C.", "T")
        val listString = sharedPreferences.getString("default_list", null) ?: return defaultList
        return listString.split(",").map { it.trim() }

    }

    private fun saveListToPreferences(list: List<String>) {
        val listString = list.joinToString(",")
        sharedPreferences.edit().putString("default_list", listString).apply()
        loadListFromPreferences()
    }

    fun complete() {
        val secondarys = listOf("中一", "中二", "中三", "中四")

        viewModelScope.launch(Dispatchers.IO) {
            val allWords = mutableListOf<Word>()
            secondarys.forEach { secondary ->
                val currentSec = loadDataFromJson("$secondary.json")
                currentSec?.chapters?.let { chapters ->
                    chapters.indices.forEach { chapter ->
                        val currentChapter = chapters.getOrNull(chapter)?.topics
                        currentChapter?.let {
                            allWords.addAll(it.topic1.topic)
                            allWords.addAll(it.topic2.topic)
                            allWords.addAll(it.topic3.topic)
                        }
                    }
                }
            }
            _words.postValue(allWords)
            // Update the StateFlow on the main thread
//            withContext(Dispatchers.Main) {
//                _words.value = allWords
//            }
        }
    }

    fun getFromList(index: Int): String {
        val currentList = _current.value.toMutableList()
        loadListFromPreferences()
        return currentList[index]
    }

    fun updateItem(index: Int, newItem: String) {
        val currentList = _current.value.toMutableList()
        if (index in currentList.indices) {
            currentList[index] = newItem
            _current.value = currentList
        }
        loadListFromPreferences()
    }

    fun flashcardGetFromList(index: Int): String {
        val defaultPath = loadListFromPreferences()
        loadListFromPreferences()
        return defaultPath[index]
    }

    fun saveContinueLearning() {
        val currentList = _current.value.toMutableList()
        val defaultList = _default.value.toMutableList()
        val saveList = intArrayOf(0, 1, 2, 3)
        defaultList.forEachIndexed { index, s ->
            defaultList[index] = currentList[saveList[index]]
        }
        loadListFromPreferences()
        saveListToPreferences(defaultList)
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
        viewModelScope.launch(Dispatchers.IO) {
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

    fun update(title: String, body: String, id: Int) {
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


    fun searchBookmarksByTitle(
        searchText: String,
        type: BookmarkSection
    ): LiveData<List<Bookmark>> {
        return bookmarksDao.searchBookmarksByTitle(searchText, type)
    }

//============================================================//

    val mcqDao = MainApplication.mcqDatabase.getMCQDao()
    private val _mcqList = MutableLiveData<List<MCQtopic>>()
    private val _mcqTopic = MutableLiveData<MCQtopic?>()
    val mcqList: MutableLiveData<List<MCQtopic>> get() = _mcqList
    val mcqTopic: MutableLiveData<MCQtopic?> get() = _mcqTopic

    init {
        loadMCQ()
    }

    fun loadMCQ() {
        viewModelScope.launch(Dispatchers.IO) {
            val mcqs = mcqDao.getAllQuestions()
            _mcqList.postValue(mcqs)
        }
    }

    fun addQuiz(topic: String, questions: List<MCQquestion>) {
        viewModelScope.launch(Dispatchers.IO) {
            val exists = mcqDao.topicExists(topic)
            if (exists == 0) {
                mcqDao.addTopic(MCQtopic(topic = topic, leftOff = 0, questions = questions))
            } else {
                Log.d("temp", "Topic already exists: $topic")
            }
            loadMCQ()
        }
    }

    fun deleteQuiz(id: Int) {
        viewModelScope.launch(Dispatchers.IO) {
            mcqDao.deleteTopic(id)
            loadMCQ()
        }
    }

    fun deleteAll() {
        viewModelScope.launch(Dispatchers.IO) {
            mcqDao.deleteAll()
            loadMCQ()
        }
    }


    fun updateLeftOff(newLeftOff: Int, topicId: Int) {
        viewModelScope.launch(Dispatchers.IO) {
            mcqDao.updateLeftOff(newLeftOff, topicId)
            loadMCQ()
        }
    }

    fun updateQuestionSelected(topicId: Int, questionIndex: Int, newSelected: String) {
        viewModelScope.launch(Dispatchers.IO) {
            mcqDao.updateSelectedQuestion(topicId, questionIndex, newSelected)
            _mcqTopic.postValue(mcqDao.getTopicById(topicId)) // Refresh the topic after update
            loadMCQ()
        }
    }

    fun checkIfTopicExists(topic: String): LiveData<Boolean> {
        val exists = MutableLiveData<Boolean>()
        viewModelScope.launch(Dispatchers.IO) {
            val count = mcqDao.topicExists(topic)
            Log.d("clicked", "topic $topic exists: ${count > 0}")
            exists.postValue(count > 0)
        }
        return exists
    }

    fun countIncorrectAnswers(topicName: String): Int {
        val questions =
            _mcqList.value?.firstOrNull { it.topic == topicName }?.questions ?: emptyList()
        return questions.count { it.selected.isNotEmpty() && it.selected != it.correct }
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
            composable(bookmarkTab.title) { Bookmarks(viewModel, navController) }
            composable(notesTab.title) { Notes(viewModel, navController) }
            composable(settingsTab.title) { SettingsView() }

            // navigation
            composable("secondary") { Secondary(viewModel, navController) }
            composable("chapter") { Chapter(viewModel, navController) }
            composable("notes") { Notes(viewModel, navController) }
            composable("addnote") { CreateNote(viewModel, navController) }
            composable("update/{itemId}") { backStackEntry ->
                val itemId = backStackEntry.arguments?.getString("itemId")?.toIntOrNull()
                UpdateNote(navController, viewModel, itemID = itemId)
            }
            composable("flashcards/{sec}/{chap}/{chap_}/{topic}.{fromHome}") { backStackEntry ->
                val secondary = backStackEntry.arguments?.getString("sec")!!
                val chapter = backStackEntry.arguments?.getString("chap")!!
                val chapter_ = backStackEntry.arguments?.getString("chap_")!!.toInt()
                val topic = backStackEntry.arguments?.getString("topic")!!
                val fromHome = backStackEntry.arguments?.getString("fromHome")!!
                FlashcardScreen(viewModel, navController, fromHome, secondary, chapter, chapter_, topic)
            }
            composable("mcq/{name}"){backStackEntry ->
                val name = backStackEntry.arguments?.getString("name") ?: "name"
                MCQ(viewModel, navController, name)

            }
            composable("mcqresults/{name}/{wrong},{correct}") {backStackEntry ->
                val wrong = backStackEntry.arguments?.getString("wrong")!!.toInt()
                val correct = backStackEntry.arguments?.getString("correct")!!.toInt()
                val name = backStackEntry.arguments?.getString("name").toString()
                MCQresults(viewModel, navController, name, wrong, correct)
            }

        }
    }

}