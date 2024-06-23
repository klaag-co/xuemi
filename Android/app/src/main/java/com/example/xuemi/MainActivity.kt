package com.example.xuemi

import android.annotation.SuppressLint
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
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.lifecycle.ViewModel
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
                                Home(viewModel, navController)
                            }
                            composable(bookmarkTab.title) {
                                Favourites()
                            }
                            composable(notesTab.title) {
                                Notes(viewModel, navController)
                            }
                            composable(settingsTab.title) {
                                Settings()
                            }
                            composable("secondary") { Secondary(viewModel, navController) }
                            composable("chapter")  { Chapter(viewModel, navController) }
                            composable("notes") { Notes(viewModel, navController)}
                            composable("addnote") { CreateNote(viewModel, navController)}
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
        mutableIntStateOf(0)
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
