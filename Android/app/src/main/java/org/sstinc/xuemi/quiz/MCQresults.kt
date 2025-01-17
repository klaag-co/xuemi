package org.sstinc.xuemi.quiz

import android.util.Log
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import org.sstinc.xuemi.MyViewModel
import org.sstinc.xuemi.NoteType
import org.sstinc.xuemi.screenTitle


@Composable
fun MCQresults(viewModel: MyViewModel, navController: NavController, topicID: Int, topicName: String, wrong: Int, correct: Int) {
    Log.d("results", "topicName: $topicName, wrong: $wrong, correct: $correct")
    val halfWrong = wrong >= correct
    val colour: Color = if (halfWrong) {
        Color(252, 216, 68)
    } else {
        Color(3, 199, 190)
    }

    var noteAdded by viewModel::noteAdded

    LaunchedEffect(Unit) {
        if (!noteAdded) {
            val body = "Correct: $correct\nWrong: $wrong\nTotal: ${correct}/${correct + wrong}"

            when {
                topicName == "oeoy" -> {
                    viewModel.add(NoteType.中四, "O 学准备考 - End-Of-Year Practice", body)
                }
                topicName == "omid" -> {
                    viewModel.add(NoteType.中四, "O 学准备考 - Mid-Year Practice", body)
                }
                topicName.substring(0, minOf(3, topicName.length)) == "EOY" -> {
                    viewModel.add(NoteType.valueOf("中${viewModel.getFromList(0)}"), "中${viewModel.getFromList(0)} - 年终考试", body)
                }
                else -> {
                    viewModel.add(NoteType.valueOf("中${viewModel.getFromList(0)}"), "${viewModel.getFromList(0)} - $topicName - 单元${viewModel.getFromList(1)}", body)
                }
            }

            noteAdded = true

        }
    }

//    BackHandler {
//        navController.popBackStack(navController.graph.startDestinationId, false)
//    }

    screenTitle(
        title = "",
        backButton = true,
        navController = navController
    ) {
        Column (
            modifier = Modifier
                .padding(top = 65.dp)
                .fillMaxWidth()
                .fillMaxHeight(0.95f),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceEvenly
        ) {
            Card(
                elevation = CardDefaults.cardElevation(defaultElevation = 10.dp),
                colors = CardDefaults.cardColors(containerColor = colour),
                shape = RoundedCornerShape(23.dp)
            ) {
                if (halfWrong) {
                    Text(
                        "继续努力！💪",
                        style = MaterialTheme.typography.displayMedium,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(15.dp)
                    )
                } else {
                    Text(
                        "好棒喔！👏",
                        style = MaterialTheme.typography.displayMedium,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(15.dp)
                    )
                }
            }
            Column {
                Text(
                    "答对了${correct}题",
                    style = MaterialTheme.typography.displayMedium,
                    color = Color(49, 195, 95)
                )
                Text(
                    "答错了${wrong}题",
                    style = MaterialTheme.typography.displayMedium,
                    color = Color(251, 53, 62)
                )
            }
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    "你总分是${correct}/${correct + wrong}",
                    style = MaterialTheme.typography.displaySmall,
                    modifier = Modifier.padding(10.dp)
                )
                Button(
                    onClick = { navController.popBackStack(navController.graph.startDestinationId, false)
                        viewModel.noteAdded = false },
                    shape = RoundedCornerShape(10.dp),
                    colors = ButtonDefaults.buttonColors(Color(0, 123, 255))
                ) {
                    Text(
                        "Home",
                        style = MaterialTheme.typography.displaySmall,
                    )
                }
            }
        }
    }

}

