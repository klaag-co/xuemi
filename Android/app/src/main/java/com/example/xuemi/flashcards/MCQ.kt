package com.example.xuemi.flashcards

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.Button
import androidx.compose.material.ButtonDefaults
import androidx.compose.material.LinearProgressIndicator
import androidx.compose.material.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.example.xuemi.MyViewModel

//@Entity
data class MCQ(
//    @PrimaryKey(autoGenerate = true)
    val id: Int,
    val topic: String,
    val leftOff: Int,
    val questions: List<String>,
    val optionList: List<List<Pair<String, String>>>
)

var questions = listOf(
    MCQ(
        id = 0,
        topic = "我的新同学",
        leftOff = 2,
        questions = listOf("1.顽皮  2.生闲气；惹气。", "你的主意糟透了，只会给我们~麻烦。", "讲义气，愿意为朋友做出牺牲"), // should be generated randomly beforehand, assume it is
        optionList = listOf(
            listOf("淘气" to "correct", "wrong answer" to "wrong", "wrong answer" to "wrong", "wrong answer" to "wrong"),
            listOf("惹" to "correct", "wrong answer" to "wrong", "wrong answer" to "wrong", "wrong answer" to "wrong"),
            listOf("两肋插刀" to "correct", "wrong answer" to "wrong", "wrong answer" to "wrong", "wrong answer" to "wrong")))
)

fun generateRandomMCQ(topicName: String): Triple<List<String>, List<List<Pair<String, String>>>, Int> {
    val topicIndex = questions.indexOfFirst { it.topic == topicName }
    val question = questions[topicIndex].questions
    val answerOptions = questions[topicIndex].optionList
    val leftOff = questions[topicIndex].leftOff

    return Triple(question, answerOptions, leftOff)
}


@Composable
fun MCQ(viewModel: MyViewModel, navController: NavController) {
    Column {
        val (question, answerOptions, leftOff) = generateRandomMCQ("我的新同学")
        var progress by remember { mutableStateOf(0f) }

        var wordDataSize by remember { mutableIntStateOf(0) }

        var currentQN by remember {
            mutableIntStateOf(0)
        }

        wordDataSize = question.size

        LinearProgressIndicator(
            progress = progress,
            color = Color(0xFF7EBDF0),
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.06f)
                .padding(vertical = 15.dp, horizontal = 20.dp)
                .clip(RoundedCornerShape(20.dp))
        )
        Text(question[currentQN], modifier = Modifier.padding(horizontal = 20.dp),fontWeight = FontWeight.Bold, style = MaterialTheme.typography.h4)
        val optionNumberList = (0..3).toList().shuffled()
        option(answerOptions[currentQN][optionNumberList[0]])
        option(answerOptions[currentQN][optionNumberList[1]])
        option(answerOptions[currentQN][optionNumberList[2]])
        option(answerOptions[currentQN][optionNumberList[3]])




        Row {
            TextButton(onClick = {
                if (progress > 0.001f) {
                    progress -= 1f/wordDataSize
                    currentQN -= 1
                }
            }) {
                Text("<")
            }
            TextButton(onClick = {
                if (progress < ((leftOff / wordDataSize.toFloat()) ?: 0f)) {
                    progress += 1f/wordDataSize
                    currentQN += 1
                }
            }) {
                Text(">")
            }
        }
        Button(onClick = { navController.navigate("home")}) {
            Text("Home")
        }
    }
}

@Composable
fun option(word: Pair<String, String>) {
    Box (Modifier.fillMaxWidth(), contentAlignment = Alignment.Center){
        Button(
            onClick = { /*TODO*/ },
            modifier = Modifier
                .fillMaxWidth(0.9f)
                .height(60.dp)
                .padding(vertical = 5.dp),
            colors = ButtonDefaults.buttonColors(Color(126, 190, 240)),
            shape = RoundedCornerShape(10.dp)
        ) {
            Text(
                word.first,
                textAlign = TextAlign.Center,
            )
        }
    }
}