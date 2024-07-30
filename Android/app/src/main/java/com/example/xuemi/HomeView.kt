package com.example.xuemi

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController


@Composable
fun Home(viewModel: MyViewModel, navController: NavController) {
    Button(onClick = { viewModel.deleteAll() }) {
        Text("DELETE ALL")

    }
    Column {// Whole app Column
        Text(
            "Home",
            fontSize = 38.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(vertical = 20.dp, horizontal = 23.dp)
        )

        Button(onClick = {
            if (viewModel.getFromList(5) == "true") {
                navController.navigate("flashcards")
            }
                         },
            colors = ButtonDefaults.buttonColors(Color(49, 113, 200)),
            //border = BorderStroke(6.dp, Brush.verticalGradient(listOf(Color.Black, Color.White))),
            shape = RoundedCornerShape(20.dp),
            modifier = Modifier
                .padding(horizontal = 26.dp)
                .padding(bottom = 10.dp))

        {
            Image(
                painter = painterResource(id = R.drawable.continue_learning),
                contentDescription = "Continue learning button",
                modifier = Modifier
                    .size(400.dp, 120.dp)

            )
        }
        Row (horizontalArrangement = Arrangement.Center, modifier = Modifier
            .fillMaxWidth()
            .fillMaxHeight(0.29f),){// 1st button row
            squaretemplate(viewModel = viewModel, navController = navController, sec4 = false, secondary = "一", 0.44f)
            squaretemplate(viewModel = viewModel, navController = navController, sec4 = false, secondary = "二", 0.8f)
        }
        Row (horizontalArrangement = Arrangement.Center, modifier = Modifier
            .fillMaxWidth()
            .fillMaxHeight(0.4f)){// 2nd button row
            squaretemplate(viewModel = viewModel, navController = navController, sec4 = false, secondary = "三",0.44f)
            squaretemplate(viewModel = viewModel, navController = navController, sec4 = true, secondary = "四",0.8f)
        }
        Button(onClick = { /*TODO*/ },
            colors = ButtonDefaults.buttonColors(Color(126, 190, 240)),
            /*border = BorderStroke(6.dp, Brush.verticalGradient(listOf(Color(90, 142, 179), Color.White))),*/
            shape = RoundedCornerShape(20.dp),
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 25.dp, vertical = 10.dp))


        {
            Text(
                text = "O 水准备考",
                style = MaterialTheme.typography.displayLarge,
                modifier = Modifier.padding(vertical = 20.dp)
            )
        }

    }

}

@Composable
fun squaretemplate(viewModel: MyViewModel, navController: NavController, sec4: Boolean, secondary: String?, size: Float) {
    Box (Modifier.fillMaxWidth(size)){
        Button(
            onClick = {
                navController.navigate("secondary")
                viewModel.updateItem(0, "$secondary")
                viewModel.updateItem(4, "false")
                if (sec4) {
                    viewModel.offButton()
                } else {
                    viewModel.onButton()
                }
            },
            colors = ButtonDefaults.buttonColors(Color(126, 190, 240)), /*border = BorderStroke(6.dp,
            Brush.verticalGradient(listOf(Color(90, 142, 179), Color.White))),*/

            shape = RoundedCornerShape(20.dp),
            modifier = Modifier
                .padding(5.dp)
                .fillMaxHeight()
                .fillMaxWidth()
        ) {
            Column {
                Text(
                    "中$secondary",
//                modifier = Modifier.padding(vertical = 26.dp, horizontal = 3.dp),
                    style = MaterialTheme.typography.displayLarge,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}