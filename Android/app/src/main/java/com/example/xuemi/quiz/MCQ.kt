package com.example.xuemi.quiz

import android.util.Log
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
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
import androidx.compose.ui.unit.sp
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


fun buttonColor(option: String, correctAnswer: String, selectedAnswer: String, showAnswer: Boolean, wrong: () -> Unit): Color {
    if (showAnswer) {
        if (option == correctAnswer) {
            return Color(107, 237, 97)
        } else if (selectedAnswer == "") {
            return Color(126, 190, 240)
        } else if (option == selectedAnswer) {
            wrong()
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
    val question = questions?.get(topicIndex)?.questions ?: emptyList()
    var leftOff = topic?.leftOff ?: 0

    var currentQN by remember { mutableIntStateOf(leftOff) }
    var selectedAnswer by remember { mutableStateOf("") }

    var wordDataSize by remember { mutableIntStateOf(question.size) }

    var progress by remember { mutableStateOf((leftOff.toFloat() + 1) / wordDataSize) }
    var enabled by remember { mutableStateOf(currentQN != leftOff) }
    var isFirst_enabled by remember { mutableStateOf(currentQN != 0) }
    var showAnswer by remember { mutableStateOf(question.getOrNull(currentQN)?.selected != "") }
    var wrong by remember { mutableStateOf(false) }



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
        question.getOrNull(currentQN)?.let {
            Text(it.question, modifier = Modifier
                .padding(horizontal = 20.dp)
                .padding(top = 10.dp), fontWeight = FontWeight.Bold, style = MaterialTheme.typography.h5)
            val optionNumberList = (0..3).toList()

            Text("正确答案是什么呢？", color = if (wrong) Color.Red else Color.White, modifier = Modifier.fillMaxWidth(), textAlign = TextAlign.Center)
            optionNumberList.forEach { number ->
                Box(Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
                    val option = it.optionList[number]
                    Button(
                        onClick = {
                            if (!showAnswer) {
                                if (selectedAnswer == "") {
                                    selectedAnswer = option
                                }
                                showAnswer = true
                                if (leftOff == currentQN) {
                                    leftOff += 1
                                }
                                viewModel.updateLeftOff(leftOff, topic!!.id)
                                viewModel.updateQuestionSelected(topic.id, currentQN, selectedAnswer)
                                enabled = true
                            }
                        },
                        modifier = Modifier
                            .fillMaxWidth(0.9f)
                            .height(90.dp)
                            .padding(vertical = 15.dp),
                        colors = ButtonDefaults.buttonColors(buttonColor(option, it.correct, selectedAnswer, showAnswer) { wrong = true }),
                        shape = RoundedCornerShape(10.dp),
                    ) {
                        Text(
                            option,
                            textAlign = TextAlign.Center,
                            fontSize = 30.sp
                        )
                    }
                }
            }
        }

        Row {
            TextButton(onClick = {
                if (currentQN > 0) {
                    currentQN -= 1
                    progress = (currentQN + 1).toFloat() / wordDataSize
                    isFirst_enabled = currentQN != 0
                    enabled = true
                    wrong = false
                    if (selectedAnswer != "") {
                        selectedAnswer = question[currentQN].selected
                    }
                }
            }, enabled = isFirst_enabled
            ) {
                Text("<")
            }
            Spacer(Modifier.fillMaxSize(0.82f))
            TextButton(onClick = {
                if (currentQN+1 == wordDataSize) {
                    Log.d("mcqresults", "end of quiz")
                    val wrongNum = viewModel.countIncorrectAnswers(topicName)
                    val correctNum = wordDataSize-wrongNum
                    navController.navigate("mcqresults/$wrongNum,$correctNum")
                    viewModel.deleteQuiz(topic!!.id)
                } else if (currentQN < leftOff) {
                    Log.d("mcqresults", "$currentQN, $leftOff")
                    currentQN += 1
                    progress = (currentQN + 1).toFloat() / wordDataSize
                    if (question[currentQN].selected != "") {
                        selectedAnswer = question[currentQN].selected
                        showAnswer = true
                        isFirst_enabled = true
                    } else {
                        selectedAnswer = ""
                        showAnswer = false
                        isFirst_enabled = true
                        wrong = false
                    }
                    enabled = currentQN != leftOff
                }
            }, enabled = enabled) {
                Text(">")
            }
        }
    }
}