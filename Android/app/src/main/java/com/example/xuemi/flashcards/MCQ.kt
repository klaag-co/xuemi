package com.example.xuemi.flashcards

import android.util.Log
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
import androidx.compose.runtime.livedata.observeAsState
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
import androidx.room.Entity
import androidx.room.PrimaryKey
import com.example.xuemi.MyViewModel

@Entity
data class MCQtopic(
    @PrimaryKey(autoGenerate = true)
    val id: Int = 0,
    var topic: String,
    val leftOff: Int,
    val questions: List<MCQquestion>
)
data class MCQquestion(
    val question: String,
    val optionList: List<String>,
    val correct: String,
    val selected: String
)


fun generateMCQ(topicName: String, questions: List<MCQtopic>): Pair<List<MCQquestion>, Int>{
    val topicIndex = questions.indexOfFirst { it.topic == topicName }
    val question = questions[topicIndex].questions
    val leftOff = questions[topicIndex].leftOff

    return Pair(question, leftOff)
}
fun buttonColor(option: String, correctAnswer: String, selectedAnswer: String, showAnswer: Boolean): Color {
    if (showAnswer) {
        if (option == correctAnswer) {
            return Color(107, 237, 97)
        } else if (selectedAnswer == "") {
            return Color(126, 190, 240)
        } else if (option == selectedAnswer) {
            return Color(235, 64, 52)
        } else {
            return Color(126, 190, 240)

        }
    } else {
        return Color(126, 190, 240)
    }
}


@Composable
fun MCQ(viewModel: MyViewModel, navController: NavController, topicName: String) {
    val questions by viewModel.mcqList.observeAsState(emptyList())
    val topicIndex = questions.indexOfFirst { it.topic == topicName }
    val topic = questions.getOrNull(topicIndex)
    val question = questions[topicIndex].questions
    var leftOff = topic?.leftOff ?: 0

    var currentQN by remember { mutableIntStateOf(leftOff) }
    var selectedAnswer by remember { mutableStateOf("") }

    var wordDataSize by remember { mutableIntStateOf(question.size) }

    var progress by remember { mutableStateOf(leftOff.toFloat() / (wordDataSize - 1)) }
    var enabled by remember { mutableStateOf(currentQN != leftOff) }
    var isFirst_enabled by remember { mutableStateOf(currentQN != 0) }
    var showAnswer by remember { mutableStateOf(topic!!.questions[currentQN].selected != "") }


    wordDataSize = question.size
    Column {
        LinearProgressIndicator(
            progress = progress,
            color = Color(0xFF7EBDF0),
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.06f)
                .padding(vertical = 15.dp, horizontal = 20.dp)
                .clip(RoundedCornerShape(20.dp))
        )
        Text(question[currentQN].question, modifier = Modifier.padding(horizontal = 20.dp), fontWeight = FontWeight.Bold, style = MaterialTheme.typography.h4)
        val optionNumberList = (0..3).toList()

        (0..3).forEach { number ->
            Box(Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
                val option = question[currentQN].optionList[optionNumberList[number]]
                Button(
                    onClick = {
                        if (!showAnswer) {
                            selectedAnswer = option
                            showAnswer = true
                            Log.d("fixleftoff", topic!!.id.toString())
                            if (leftOff == currentQN) {
                                leftOff+=1
                            }
                            viewModel.updateLeftOff(leftOff, topic.id)
                            Log.d("fixleftoff", "after, currentQN: $currentQN, leftoff: $leftOff")
                            enabled = true
                        }
                    },
                    modifier = Modifier
                        .fillMaxWidth(0.9f)
                        .height(60.dp)
                        .padding(vertical = 5.dp),
                    colors = ButtonDefaults.buttonColors(buttonColor(option, question[currentQN].correct, selectedAnswer, showAnswer)),
                    shape = RoundedCornerShape(10.dp),
                ) {
                    Text(
                        option,
                        textAlign = TextAlign.Center,
                    )
                }
            }
        }

        Row {
            TextButton(onClick = {
                if (currentQN > 0) {
                    currentQN -= 1
                    progress -= 1f / (wordDataSize - 1)
                    isFirst_enabled = currentQN != 0
                    enabled = true
                }
            }, enabled = isFirst_enabled
            ) {
                Text("<")
            }
            TextButton(onClick = {
                if (currentQN < leftOff) {
                    currentQN += 1
                    progress += 1f / (wordDataSize - 1)
                    selectedAnswer = ""
                    showAnswer = false
                    enabled = currentQN != leftOff
                    isFirst_enabled = true
                }
            }, enabled = enabled) {
                Text(">")
            }
        }
    }
}