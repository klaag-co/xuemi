package org.sstinc.xuemi

import android.annotation.SuppressLint
import android.app.Application
import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.room.Room
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.sstinc.xuemi.db.BookmarksDatabase
import org.sstinc.xuemi.db.BookmarksRepository
import org.sstinc.xuemi.db.FoldersDatabase
import org.sstinc.xuemi.db.MCQDatabase
import org.sstinc.xuemi.db.MIGRATION_1_2
import org.sstinc.xuemi.db.NotesDatabase
import org.sstinc.xuemi.quiz.Chapter
import org.sstinc.xuemi.quiz.FlashcardScreen
import org.sstinc.xuemi.quiz.JsonReader
import org.sstinc.xuemi.quiz.MCQ
import org.sstinc.xuemi.quiz.MCQquestion
import org.sstinc.xuemi.quiz.MCQresults
import org.sstinc.xuemi.quiz.MCQtopic
import org.sstinc.xuemi.quiz.Secondary
import org.sstinc.xuemi.quiz.Word


// now transfer the loading to viewmodel

class MainApplication: Application() {
    companion object {
        lateinit var notesDatabase: NotesDatabase
        lateinit var bookmarksDatabase: BookmarksDatabase
        lateinit var mcqDatabase: MCQDatabase
        lateinit var foldersDatabase: FoldersDatabase
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
        ).addMigrations(MIGRATION_1_2).fallbackToDestructiveMigration().build()
        mcqDatabase = Room.databaseBuilder(
            applicationContext,
            MCQDatabase::class.java,
            MCQDatabase.NAME
        ).build()
        foldersDatabase = Room.databaseBuilder(
            applicationContext,
            FoldersDatabase::class.java,
            FoldersDatabase.NAME
        ).build()
    }
}

enum class SecondaryType {
    SEC1,
    SEC2,
    SEC3,
    SEC4
}

class MyViewModel( appContext: Context, application: Application ) : AndroidViewModel(application) {
    private val sharedPreferences: SharedPreferences =
        application.getSharedPreferences("my_prefs", Context.MODE_PRIVATE)
    private val _current: MutableStateFlow<List<String>> = MutableStateFlow(loadListFromPreferences("current_list"))
    private val _continue: MutableStateFlow<List<String>> = MutableStateFlow(loadListFromPreferences("continue_list"))

    // o levels
    private val _eoy: MutableStateFlow<List<Word>> = MutableStateFlow(emptyList())
    val eoy: MutableStateFlow<List<Word>> = _eoy
    private val _mid: MutableStateFlow<List<Word>> = MutableStateFlow(emptyList())
    val mid: MutableStateFlow<List<Word>> = _mid
    var noteAdded by mutableStateOf(false)


    private val _secondaryStates: MutableMap<SecondaryType, MutableStateFlow<List<Word>?>> =
        SecondaryType.entries.associateWith { MutableStateFlow<List<Word>?>(null) }.toMutableMap()
    val secondaryStates: Map<SecondaryType, StateFlow<List<Word>?>> = _secondaryStates

    // vocab list
    private val _sectionedData = MutableStateFlow<List<List<Word>>>(emptyList())
    val sectionedData: StateFlow<List<List<Word>>> = _sectionedData.asStateFlow()

    // temp folder item list
    private val _tempFolder = MutableStateFlow<List<Word>>(emptyList())
    val tempFolder: StateFlow<List<Word>> = _tempFolder.asStateFlow()

    init {
        viewModelScope.launch {
            if (!sharedPreferences.contains("current_list")) {
                saveListToPreferences("current_list", listOf("S", "C", "C.", "T", "Q", "W."))
            }
            if (!sharedPreferences.contains("continue_list")) {
                saveListToPreferences("continue_list", listOf("S", "C", "C.", "T"))

            }
            loadListFromPreferences("current_list")
            loadListFromPreferences("continue_list")
            complete_words(listOf("中一", "中二", "中三", "中四"))

        }
    }

    //============================================================//


    private var jsonReader: JsonReader? = JsonReader(appContext)
    private val _loadedData = MutableStateFlow<Secondary?>(null)
    val loadedData: StateFlow<Secondary?> get() = _loadedData


    suspend fun loadDataFromJson(name: String): Secondary? {
        return jsonReader?.readJsonFile(name)
    }


    fun loadData(name: String) {
        viewModelScope.launch {
            val data = loadDataFromJson(name)
            _loadedData.value = data
        }
    }

    private fun loadListFromPreferences(name: String): List<String> {
        val defaultList = listOf("S", "C", "C.", "T", "Q", "W.")
        val listString = sharedPreferences.getString(name, null) ?: return defaultList
        return listString.split(",").map { it.trim() }
    }

    private fun saveListToPreferences(name: String, list: List<String>) {
        val listString = list.joinToString(",")
        sharedPreferences.edit().putString(name, listString).apply()
        loadListFromPreferences(name)
    }


    private suspend fun sectioning(): List<List<Word>> {
        val sectionNames = listOf("中一", "中二", "中三", "中四")

        return sectionNames.map { sectionName ->

            withContext(Dispatchers.IO) {
                val data = loadDataFromJson("$sectionName.json")

                val chapterData = data?.chapters

                val words = mutableListOf<Word>()
                chapterData?.forEach { chapter ->
                    chapter.topics.let { topic ->
                        words.addAll(topic.topic1.topic)
                        words.addAll(topic.topic2.topic)
                        words.addAll(topic.topic3.topic)
                    }
                }
                words
            }
        }
    }
    fun addTempFolder(item: Word) {

        _tempFolder.value = _tempFolder.value + item
        Log.d("temp", "oh! ${_tempFolder.value}")
    }

    fun selectJson(num: Int): Deferred<List<Word>> {
        return viewModelScope.async(Dispatchers.IO) {
            sectionedData.value[num] // try to load in viewmodel
        }
    }

    fun loadJson() {
        viewModelScope.launch(Dispatchers.IO) {
            _sectionedData.value = sectioning()
        }
    }




    private fun complete(secondaryList: List<String>, excludeLastTwo: Boolean = false): Deferred<List<Word>> {
        return viewModelScope.async(Dispatchers.IO) {
            val allWords = mutableListOf<Word>()

            secondaryList.forEachIndexed { index, secondaryName ->
                val secondaryType = SecondaryType.entries.getOrNull(index) ?: return@forEachIndexed
                val secondaryData = loadDataFromJson("$secondaryName.json")

                val chaptersToProcess = if (excludeLastTwo && secondaryName == "中四") {
                    secondaryData?.chapters?.dropLast(2)
                } else {
                    secondaryData?.chapters
                }

                // Extract words from the selected chapters
                val wordsForSecondary = mutableListOf<Word>()
                chaptersToProcess?.forEach { chapter ->
                    chapter.topics.let { topics ->
                        wordsForSecondary.addAll(topics.topic1.topic)
                        wordsForSecondary.addAll(topics.topic2.topic)
                        wordsForSecondary.addAll(topics.topic3.topic)
                    }
                }

                _secondaryStates[secondaryType]?.value = wordsForSecondary

                allWords.addAll(wordsForSecondary)
            }

            withContext(Dispatchers.Main) {
                if (excludeLastTwo) {
                    _mid.value = allWords
                } else {
                    _eoy.value = allWords
                }
            }
            allWords
        }
    }
    private fun complete_words(secondarys: List<String>) {
        viewModelScope.launch {
            val eoy = complete(secondarys, false).await()
            val mid = complete(secondarys, true).await()
            _eoy.value = eoy
            _mid.value = mid
        }
    }


    fun getFromList(index: Int): String {
        val currentList = _current.value.toMutableList()
        loadListFromPreferences("current_list")
        return currentList[index]
    }

    fun updateItem(index: Int, newItem: String) {
        val currentList = _current.value.toMutableList()
        if (index in currentList.indices) {
            currentList[index] = newItem
            _current.value = currentList
        }
        loadListFromPreferences("current_list")
    }

    fun flashcardGetFromList(index: Int): String {
        val continuePath = loadListFromPreferences("continue_list")
        loadListFromPreferences("continue_list")
        return continuePath[index]
    }

    fun saveContinueLearning() {
        val currentList = _current.value.toMutableList()
        val continueList = _continue.value.toMutableList()
        if (continueList.size >= 4 && currentList.size >= 4) {
            // Update currentList with the first four elements of defaultList
            for (i in 0 until 4) {
                continueList[i] = currentList[i]
            }

            // If you need to update the StateFlow or MutableStateFlow with the new list
            _current.value = currentList
        }
        loadListFromPreferences("continue_list")
        loadListFromPreferences("current_list")
        saveListToPreferences("continue_list", continueList)
        saveListToPreferences("current_list", currentList)
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


    fun addBookmark(section: BookmarkSection, word: String, chapter: String, topic: String, leftOff: Int) {
        viewModelScope.launch(Dispatchers.IO) {
            bookmarksDao.addBookmark(
                Bookmark(
                    type = section,
                    word = word,
                    chapter = chapter,
                    topic = topic,
                    leftOff = leftOff
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
            val topicIndex = mcqList.value?.indexOfFirst { it.topic == topic }
            if (exists == 0 || topicIndex == null || topicIndex == -1) {
                mcqDao.addTopic(MCQtopic(topic = topic, leftOff = 0, questions = questions))
            } else {
                // Topic exists, so check if it needs to be deleted and re-added
                val topicInList = mcqList.value!![topicIndex]
                Log.d("MCQCHECK", ("leftoff: ${topicInList.leftOff}, question.size: ${questions.size}").toString())
                if (topicInList.leftOff == questions.size) {
                    deleteQuiz(topicInList.id)
                    mcqDao.addTopic(MCQtopic(topic = topic, leftOff = 0, questions = questions))
                } else {
                    Log.d("temp", "Topic already exists and leftOff < questions.size: $topic")
                }
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
            exists.postValue(count > 0)
        }
        return exists
    }

    fun countIncorrectAnswers(topicName: String): Int {
        val questions =
            _mcqList.value?.firstOrNull { it.topic == topicName }?.questions ?: emptyList()
        return questions.count { it.selected.isNotEmpty() && it.selected != it.correct }
    }
    //============================================================//

    val foldersDao = MainApplication.foldersDatabase.getFoldersDao()
    private val _folders = MutableLiveData<List<Afolder>>()

    val folders: LiveData<List<Afolder>> get() = _folders

    fun addFolder(folder: Afolder) {
        viewModelScope.launch(Dispatchers.IO) {
            foldersDao.addFolder(folder)
        }
    }
    fun deleteFolder(id: Int) {
        viewModelScope.launch(Dispatchers.IO) {
            foldersDao.deleteFolder(id)
        }
    }

    fun selectFolder(id: Int) {
        viewModelScope.launch(Dispatchers.IO) {
            foldersDao.getFolderByID(id)
        }
    }
}



data class NavItem(
    val label: String,
    val selected: Int,
    val unselected: Int
)

@SuppressLint("UnusedMaterial3ScaffoldPaddingParameter")
@Composable
fun BottomNavBar(viewModel: MyViewModel, navController: NavHostController) {
    val itemList = listOf(
        NavItem("Home", R.drawable.home, R.drawable.o_home),
        NavItem("Bookmarks", R.drawable.bookmark, R.drawable.o_bookmark),
        NavItem("Notes", R.drawable.notes, R.drawable.o_notes),
        NavItem("Vocabulary", R.drawable.vocab, R.drawable.vocab)
    )

    var selectedTabIndex by rememberSaveable {
        mutableIntStateOf(0)
    }

    LaunchedEffect(navController) {
        navController.currentBackStackEntryFlow.collect { backStackEntry ->
            when (backStackEntry.destination.route) {
                "home" -> selectedTabIndex = 0
                "bookmarks" -> selectedTabIndex = 1
                "notes" -> selectedTabIndex = 2
                "vocabulary" -> selectedTabIndex = 3
            }
        }
    }

    Scaffold(
//        topBar = {
//            Row(horizontalArrangement = Arrangement.End, modifier = Modifier
//                .fillMaxWidth()
//                .fillMaxHeight(0.3f)
//                .padding(vertical = 10.dp, horizontal = 15.dp)) {
//                IconButton(onClick = { navController.navigate("settings") }) {
//                    Icon(Icons.Default.Settings, contentDescription = "Settings",  modifier = Modifier.fillMaxSize())
//                }
//            }
//        },
        bottomBar = {
            NavigationBar {
                itemList.forEachIndexed { index, navItem ->
                    NavigationBarItem(
                        selected = selectedTabIndex == index,
                        onClick = {
                            selectedTabIndex = index
                            navController.navigate(navItem.label) {
                                popUpTo("home") {
                                    inclusive = navItem.label == "home" // Pop up to "home" when navigating away from it
                                    saveState = true
                                }
                                launchSingleTop = true
                                restoreState = true
                            }
                        },
                        icon = {
                            Icon(
                                painter = painterResource(
                                    id = if (selectedTabIndex == index) navItem.selected else navItem.unselected
                                ),
                                contentDescription = null
                            )
                        },
                        label = {
                            Text(navItem.label)
                        }
                    )
                }
            }
        }
    ) {
        NavHost(
            navController,
            startDestination = "home",
            modifier = Modifier.padding()
        ) {
            // Tabs
            composable("home") { Home(viewModel, navController) }
            composable("bookmarks") { Bookmarks(viewModel, navController) }
            composable("notes") { Notes(viewModel, navController) }
            composable("vocabulary") { Vocabulary(viewModel, navController) }

            // Additional Routes
            composable("settings") { SettingsView(navController) }
            composable("helloWorld") { HelloWorldScreen(navController) }
            composable("secondary") { Secondary(viewModel, navController) }
            composable("chapter") { Chapter(viewModel, navController) }
            composable("addnote") { CreateNote(viewModel, navController) }
            composable("update/{itemId}") { backStackEntry ->
                val itemId = backStackEntry.arguments?.getString("itemId")?.toIntOrNull()
                UpdateNote(navController, viewModel, itemID = itemId)
            }
            composable("flashcards/{sec}/{chap}/{chap_}/{topic}/{leftoff}.{fromHome}") { backStackEntry ->
                val secondary = backStackEntry.arguments?.getString("sec")!!
                val chapter = backStackEntry.arguments?.getString("chap")!!
                val chapter_ = backStackEntry.arguments?.getString("chap_")!!.toInt()
                val topic = backStackEntry.arguments?.getString("topic")!!
                val fromHome = backStackEntry.arguments?.getString("fromHome")!!
                val leftOff = backStackEntry.arguments?.getString("leftoff")!!.toInt()
                FlashcardScreen(viewModel, navController, fromHome, secondary, chapter, chapter_, topic, if (leftOff != 0) leftOff else 0)
            }
            composable("mcq/{name}") { backStackEntry ->
                val name = backStackEntry.arguments?.getString("name") ?: "name"
                MCQ(viewModel, navController, name)
            }
            composable("mcqresults/{id}/{name}/{wrong},{correct}") { backStackEntry ->
                val id = backStackEntry.arguments?.getString("id")!!.toInt()
                val wrong = backStackEntry.arguments?.getString("wrong")!!.toInt()
                val correct = backStackEntry.arguments?.getString("correct")!!.toInt()
                val name = backStackEntry.arguments?.getString("name").toString()
                MCQresults(viewModel, navController, id, name, wrong, correct)
            }
            composable("olevel") { olevel(viewModel, navController) }
            composable("addvocab") { AddVocabulary(viewModel)}
        }
    }
}