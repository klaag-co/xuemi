package com.example.xuemi

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.absolutePadding
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import androidx.navigation.compose.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

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


    private val _showButton = MutableStateFlow(true)
    val showButton: StateFlow<Boolean> = _showButton

    fun offButton() {
        _showButton.value = false
    }
    fun onButton() {
        _showButton.value = true
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun HomeNav() {
    val navController = rememberNavController()
    val viewModel: MyViewModel = viewModel()

    NavHost(navController, startDestination = "home") {
        composable("home") { Home(viewModel, navController) }
        composable("secondary") { Secondary(viewModel, navController) }
        composable("chapter")  { Chapter(viewModel, navController) }
        composable("topic") { Topic(viewModel) }
    }
}

@Composable
fun Home(viewModel: MyViewModel, navController: NavController) {
    Column {// Whole app Column
        Text(
            "Home",
            fontSize = 45.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(vertical = 20.dp, horizontal = 23.dp)
        )

        Button(onClick = { },
            colors = ButtonDefaults.buttonColors(Color(49, 113, 200)),
            //border = BorderStroke(6.dp, Brush.verticalGradient(listOf(Color.Black, Color.White))),
            shape = RoundedCornerShape(20.dp),
            modifier = Modifier.padding(horizontal = 26.dp))
        {
            Image(
                painter = painterResource(id = R.drawable.continue_learning),
                contentDescription = "Continue learning button",
                modifier = Modifier
                    .size(400.dp, 120.dp)

            )
        }
        Row {// 1st button row
            squaretemplate(viewModel = viewModel, navController = navController, sec4 = false, secondary = "1", top = 14, bottom = 14, right = 12, left = 28)
            squaretemplate(viewModel = viewModel, navController = navController, sec4 = false, secondary = "2", top = 14, bottom = 14, right = 1, left = 1)

        }
        Row {// 2nd button row
            squaretemplate(viewModel = viewModel, navController = navController, sec4 = false, secondary = "3", top = 0, bottom = 0, right = 12, left = 28)
            squaretemplate(viewModel = viewModel, navController = navController, sec4 = true, secondary = "4", top = 0, bottom = 0, right = 1, left = 1)

        }
        Button(onClick = { /*TODO*/ },
            colors = ButtonDefaults.buttonColors(Color(126, 190, 240)),
            /*border = BorderStroke(6.dp, Brush.verticalGradient(listOf(Color(90, 142, 179), Color.White))),*/
            shape = RoundedCornerShape(20.dp),
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 25.dp, vertical = 15.dp))


        {
            Text(
                text = "O-Level\n\nPractice",
                fontSize = 40.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(vertical = 5.dp)
            )
        }

    }

}

@Composable
fun squaretemplate(viewModel: MyViewModel, navController: NavController, sec4: Boolean, secondary: String?, top: Int, bottom: Int, right: Int, left: Int) {
    Button(
        onClick = { navController.navigate("secondary")
                  viewModel.updateItem(0, "$secondary")
                  if (sec4) {
                      viewModel.offButton()
                  } else {
                      viewModel.onButton()
                  }
                  },
        colors = ButtonDefaults.buttonColors(Color(126, 190, 240)), /*border = BorderStroke(6.dp,
                Brush.verticalGradient(listOf(Color(90, 142, 179), Color.White))),*/
        modifier = Modifier.absolutePadding(
            top = top.dp,
            bottom = bottom.dp,
            right = right.dp,
            left = left.dp
        ),
        shape = RoundedCornerShape(20.dp)
    ) {
        Column {
            Text(
                text = "Secondary",
                fontSize = 24.sp,
            )
            Text(
                text = "$secondary",
                fontSize = 65.sp,
                modifier = Modifier
                    .padding(horizontal = 35.dp)
                    .absolutePadding(bottom = 10.dp),
                fontWeight = FontWeight.Bold
            )
        }
    }
}