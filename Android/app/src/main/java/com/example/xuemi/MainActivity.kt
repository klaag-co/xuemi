package com.example.xuemi

import android.annotation.SuppressLint
import android.content.Context
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.BadgedBox
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.example.xuemi.ui.theme.XuemiTheme
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

data class TabBarItem(
    val title: String,
    val selectedIcon: Int,
    val unselectedIcon: Int,
    val badgeAmount: Int? = null
)
class MyViewModel : ViewModel() {
    private val _items = MutableStateFlow(listOf("N", "N", "N", "N"))
    val items: StateFlow<List<String>> = _items

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

    private val _examNotes = MutableStateFlow(Section(
        "EXAM@", "EXAM#"
    ))

    val examNotes: MutableStateFlow<Section> = _examNotes


    private val _notesNotes = MutableStateFlow(listOf("note1", "note2", "note3"))
    val notesNotes: MutableStateFlow<List<String>> = _notesNotes

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

class MainActivity : ComponentActivity() {
    private val viewModel: MyViewModel by viewModels()

    @SuppressLint("UnusedMaterial3ScaffoldPaddingParameter")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {

            // setting up the individual tabs
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
                unselectedIcon = R.drawable.o_settings,
            )

            // creating a list of all the tabs
            val tabBarItems = listOf(homeTab, bookmarkTab, notesTab, settingsTab)

            // creating our navController
            val navController = rememberNavController()

            XuemiTheme {
                // A surface container using the 'background' color from the theme
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    Scaffold(bottomBar = { TabView(tabBarItems, navController) }) {
                        NavHost(navController = navController, startDestination = homeTab.title) {
                            composable(homeTab.title) {
                                HomeNav(viewModel)
                            }
                            composable(bookmarkTab.title) {
                                Favourites()
                            }
                            composable(notesTab.title) {
                                Notes(viewModel)
                            }
                            composable(settingsTab.title) {
                                Settings()
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun TabView(tabBarItems: List<TabBarItem>, navController: NavController) {
    var selectedTabIndex by rememberSaveable {
        mutableStateOf(0)
    }

    NavigationBar {
        // looping over each tab to generate the views and navigation for each item
        tabBarItems.forEachIndexed { index, tabBarItem ->
            NavigationBarItem(
                selected = selectedTabIndex == index,
                onClick = {
                    selectedTabIndex = index
                    navController.navigate(tabBarItem.title)
                },
                icon = {
                    TabBarIconView(
                        isSelected = selectedTabIndex == index,
                        selectedIcon = tabBarItem.selectedIcon,
                        unselectedIcon = tabBarItem.unselectedIcon,
                        title = tabBarItem.title
                    )
                },
                label = {Text(tabBarItem.title)})
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TabBarIconView(
    isSelected: Boolean,
    selectedIcon: Int,
    unselectedIcon: Int,
    title: String,
) {
    BadgedBox(badge = { }) {
        Icon(
            painter = painterResource(id = if (isSelected) {selectedIcon} else {unselectedIcon}),
            contentDescription = title
        )
    }
}


@Preview(showSystemUi = true)
@Composable
fun GreetingPreview() {
    XuemiTheme {
        Secondary(viewModel = MyViewModel(), navController = rememberNavController())
    }
}
