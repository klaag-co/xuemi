package org.sstinc.xuemi

import android.util.Log
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import org.sstinc.xuemi.quiz.generateListOfMCQQuestions


@Composable
fun Home(viewModel: MyViewModel, navController: NavController) {
    Column {// Whole app Column
        Text(
            "Home",
            fontSize = 38.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(vertical = 20.dp, horizontal = 20.dp)
        )

        Button(onClick = {
            if (viewModel.flashcardGetFromList(3) != "T") {
                navController.navigate("flashcards/${viewModel.flashcardGetFromList(0)}/${viewModel.flashcardGetFromList(1)}/${viewModel.flashcardGetFromList(2)}/${viewModel.flashcardGetFromList(3)}.home")
            } },
            colors = ButtonDefaults.buttonColors(Color(49, 113, 200)),
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
        Button(onClick = {
            navController.navigate("olevel")
        },
            colors = ButtonDefaults.buttonColors(Color(126, 190, 240)),
            /*border = BorderStroke(6.dp, Brush.verticalGradient(listOf(Color(90, 142, 179), Color.White))),*/
            shape = RoundedCornerShape(20.dp),
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 25.dp, vertical = 10.dp))


        {
            Text(
                text = "O 学准备考",
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
            colors = ButtonDefaults.buttonColors(Color(126, 190, 240)),
            shape = RoundedCornerShape(20.dp),
            modifier = Modifier
                .padding(5.dp)
                .width(170.dp)
                .height(155.dp)
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                Text(
                    text = "中$secondary",
                    style = MaterialTheme.typography.displayLarge,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}

@Composable
fun olevel(viewModel: MyViewModel, navController: NavController) {
    val eoy by viewModel.eoy.collectAsState()
    val mid by viewModel.mid.collectAsState()
    val topicExists = "oeoy".let { viewModel.checkIfTopicExists(it) }
    val topicExistsState by topicExists.observeAsState(false)

    val navigateToMCQ = remember { mutableStateOf(false) }
    var clicked = remember { mutableStateOf("") }

    LaunchedEffect(Unit) {
        if (!topicExistsState) {
            viewModel.updateItem(0, "四")
            val egeneratedQuestions = generateListOfMCQQuestions(eoy, true)
            val mgeneratedQuestions = generateListOfMCQQuestions(mid, true)
            viewModel.addQuiz(
                topic = "oeoy",
                questions = egeneratedQuestions
            )
            viewModel.addQuiz(
                topic = "omid",
                questions = mgeneratedQuestions
            )
        } else {
            Log.d("temp", "topic already exists (Home)")
        }
    }

    LaunchedEffect(topicExistsState, navigateToMCQ.value) {
        if (navigateToMCQ.value) {
            if (topicExistsState) {
                if (clicked.value == "eoy") {
                    navController.navigate("mcq/oeoy")
                } else {
                    navController.navigate("mcq/omid")
                }
            }
            navigateToMCQ.value = false
        }
    }
    screenTitle(
        title = "O 学准备考",
        backButton = true,
        navController = navController
    ) {
        Column(Modifier.fillMaxSize(), verticalArrangement = Arrangement.Center) {
            Button(
                onClick = {
                    navigateToMCQ.value = true
                    clicked.value = "mid"
                },
                colors = ButtonDefaults.buttonColors(Color(217, 217, 217)),
                shape = RoundedCornerShape(20.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 7.dp)
            ) {
                Column {
                    Text(
                        text = "Mid-Year Practice",
                        color = Color.Black,
                        fontSize = 28.sp,
                        modifier = Modifier
                            .padding(horizontal = 5.dp, vertical = 5.dp)

                    )
                }
            }
            Button(
                onClick = {
                    navigateToMCQ.value = true
                    clicked.value = "eoy"
                },
                colors = ButtonDefaults.buttonColors(Color(217, 217, 217)),
                shape = RoundedCornerShape(20.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 7.dp)
            ) {
                Column {
                    Text(
                        text = "End-Of-Year Practice",
                        color = Color.Black,
                        fontSize = 28.sp,
                        modifier = Modifier
                            .padding(horizontal = 5.dp, vertical = 5.dp)

                    )
                }
            }
        }
    }
}