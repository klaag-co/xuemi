package com.example.xuemi

import android.annotation.SuppressLint
import android.content.Context
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import androidx.navigation.compose.rememberNavController
import com.example.xuemi.ui.theme.XuemiTheme


data class TabBarItem(
    val title: String,
    val selectedIcon: Int,
    val unselectedIcon: Int,
    val badgeAmount: Int? = null
)


class MainActivity : ComponentActivity() {
    private val context: Context = this
    @SuppressLint("UnusedMaterial3ScaffoldPaddingParameter")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            XuemiTheme {
                val navController = rememberNavController()
                // A surface container using the 'background' color from the theme
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
//                    HomeNav(
//                        viewModel = MyViewModel(context, application)
//                    )
                    BottomNavBar(MyViewModel(context, application), navController)
                }
            }
        }
    }

}

//@Composable
//fun TabView(tabBarItems: List<TabBarItem>, navController: NavController) {
//    var selectedTabIndex by rememberSaveable {
//        mutableIntStateOf(0)
//    }
//    Scaffold(
//        bottomBar = {
//            NavigationBar {
//                // looping over each tab to generate the views and navigation for each item
//                tabBarItems.forEachIndexed { index, tabBarItem ->
//                    NavigationBarItem(
//                        selected = selectedTabIndex == index,
//                        onClick = {
//                            selectedTabIndex = index
//                            navController.navigate(tabBarItem.title)
//                        },
//                        icon = {
//                            TabBarIconView(
//                                isSelected = selectedTabIndex == index,
//                                selectedIcon = tabBarItem.selectedIcon,
//                                unselectedIcon = tabBarItem.unselectedIcon,
//                                title = tabBarItem.title
//                            )
//                        },
//                        label = { Text(tabBarItem.title) })
//                }
//            }
//        }
//    ) {}
//}

//@OptIn(ExperimentalMaterial3Api::class)
//@Composable
//fun TabBarIconView(
//    isSelected: Boolean,
//    selectedIcon: Int,
//    unselectedIcon: Int,
//    title: String,
//) {
//    BadgedBox(badge = { }) {
//        Icon(
//            painter = painterResource(id = if (isSelected) {selectedIcon} else {unselectedIcon}),
//            contentDescription = title
//        )
//    }
//}

