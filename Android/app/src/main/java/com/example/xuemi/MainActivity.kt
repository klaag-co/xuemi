package org.sstinc.xuemi

import android.annotation.SuppressLint
import android.content.Context
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.appcompat.app.AppCompatDelegate
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import androidx.navigation.compose.rememberNavController
import org.sstinc.xuemi.ui.theme.XuemiTheme


class MainActivity : ComponentActivity() {
    private val context: Context = this
    @SuppressLint("UnusedMaterial3ScaffoldPaddingParameter")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO)
        setContent {
            XuemiTheme {
                val navController = rememberNavController()
                // A surface container using the 'background' color from the theme
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    BottomNavBar(MyViewModel(context, application), navController)
                }
            }
        }
    }

}

// custom
@Composable
fun backButton(text: String, onClick: () -> Unit) {
    TextButton(
        onClick = {
            onClick()
        },
    ) {
        Text(
            text = "< $text",
            color = Color(70, 156, 253),
            fontSize = 19.sp,
            fontWeight = FontWeight.Bold,
        )
    }
}

@SuppressLint("UnusedMaterial3ScaffoldPaddingParameter")
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun screenTitle(title: String, backButton: Boolean, navController: NavController, content: @Composable () -> Unit = {}) {
    if (title != "") {
        if (backButton) {
            Scaffold(
                topBar = {
                    TopAppBar(
                        title = {},
                        navigationIcon = {
                            IconButton(onClick = { navController.popBackStack() }) {
                                Icon(Icons.Filled.ArrowBack, contentDescription = "Back")
                            }

                        }
                    )
                }
            ) {
                LazyColumn(
                    Modifier.padding(
                        start = 20.dp,
                        end = 20.dp,
                        top = 10.dp,
                        bottom = 90.dp
                    )
                ) {
                    item {
                        Text(
                            title,
                            fontSize = 45.sp,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(top = 50.dp, bottom = 10.dp)
                        )
                        content()
                    }
                }

            }
        } else {
            LazyColumn(Modifier.padding(start = 20.dp, end = 20.dp, bottom = 90.dp)) {
                item {
                    Text(
                        title,
                        fontSize = 44.sp,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(vertical = 10.dp)
                    )
                    content()
                }
            }
        }
    } else {
        if (backButton) {
            Scaffold(
                topBar = {
                    TopAppBar(
                        title = {},
                        navigationIcon = {

                            IconButton(onClick = { navController.popBackStack() }) {
                                Icon(Icons.Filled.ArrowBack, contentDescription = "Back")
                            }

                        }
                    )
                }
            ) {
                LazyColumn(Modifier.padding(start = 20.dp, end = 20.dp, top = 10.dp, bottom = 90.dp)) {
                    item {
                        content()
                    }
                }
            }

        }
        else {
            LazyColumn(Modifier.padding(start = 20.dp, end = 20.dp, top = 10.dp, bottom = 90.dp)) {
                item {
                    content()
                }
            }
        }
    }
}