package com.example.xuemi

import android.app.Application
import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.room.Room
import com.example.xuemi.db.NotesDatabase
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class MainApplication: Application() {
    companion object {
        lateinit var notesDatabase: NotesDatabase
    }

    override fun onCreate() {
        super.onCreate()
        notesDatabase = Room.databaseBuilder(
            applicationContext,
            NotesDatabase::class.java,
            NotesDatabase.NAME
        ).build()
    }
}

class MyViewModel : ViewModel() {
    private val _items = MutableStateFlow(listOf("N", "N", "N", "N"))

    fun updateItem(index: Int, newItem: String) {
        val currentList = _items.value.toMutableList()
        if (index in currentList.indices) {
            currentList[index] = newItem
            _items.value = currentList
        }
    }

    fun getFromList(index: Int): String {
        val currentList = _items.value.toMutableList()
        return currentList[index]
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
    val notesList: LiveData<List<Note>> = notesDao.getAllNotes()


    fun add(type: NoteType, title: String, body: String) {
        viewModelScope.launch (Dispatchers.IO) {
            notesDao.addNote(Note(type = type, title = title, body = body))
        }
    }
    fun delete(id: Int) {
        viewModelScope.launch(Dispatchers.IO) {
            notesDao.deleteNote(id)
        }
    }

    fun update(title: String, body: String, id: Int){
        viewModelScope.launch(Dispatchers.IO) {
            notesDao.updateNote(title, body, id)
        }
    }
//    fun getNoteById(noteId: Int): LiveData<Note?> {
//        return notesDao.getNoteById(noteId)
//    }


//============================================================//

    private val _isSearching = MutableStateFlow(false)
    val isSearching = _isSearching.asStateFlow()

//============================================================//

    private val _searchText = MutableStateFlow("")
    val searchText = _searchText.asStateFlow()

//============================================================//

//private val _searchList = MutableStateFlow(countries)
//val countriesList = searchText
//    .combine(_countriesList) { text, countries ->//combine searchText with _contriesList
//        if (text.isBlank()) { //return the entery list of countries if not is typed
//            countries
//        }
//        countries.filter { country ->// filter and return a list of countries based on the text the user typed
//            country.uppercase().contains(text.trim().uppercase())
//        }
//    }.stateIn(//basically convert the Flow returned from combine operator to StateFlow
//        scope = viewModelScope,
//        started = SharingStarted.WhileSubscribed(5000),//it will allow the StateFlow survive 5 seconds before it been canceled
//        initialValue = _countriesList.value
//    )
}