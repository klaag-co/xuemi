package org.sstinc.xuemi.quiz

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
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.runtime.mutableFloatStateOf
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
import org.sstinc.xuemi.MyViewModel

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
    val topics by viewModel.mcqList.observeAsState(emptyList())

    val topic = topics.find{ it.topic == topicName }
    val questions = topic?.questions?: emptyList()
    val questionsSize = questions.size
//    val num = question.get(topicIndex).optionList.size

    var currentQNindex by remember { mutableIntStateOf(topic?.leftOff ?: 0) }
    if (currentQNindex >= questionsSize && questionsSize > 0) {
        currentQNindex = questionsSize - 1
    }

    val currentQN = questions.getOrNull(currentQNindex)
    val options = currentQN?.optionList?: emptyList()

    var selectedAnswer by remember { mutableStateOf(currentQN?.selected ?: "") }

    val showAnswer = selectedAnswer.isNotEmpty()

    val canGoPrev = currentQNindex > 0
    val canGoNext = currentQNindex < (topic?.leftOff ?: 0)



    Column {
//        Log.d("nexterror", "$currentQNindex < ${topic?.leftOff} = $canGoNext, size: $questionsSize")
        Log.d("nexterror", "progress: ${(currentQNindex + 1).toFloat() / questionsSize}")
        // .PROGRESS BAR.
        LinearProgressIndicator(
            progress = ((currentQNindex + 1).toFloat() / questionsSize),
            color = Color(0xFF7EBDF0),
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.06f)
                .padding(vertical = 15.dp, horizontal = 20.dp)
                .clip(RoundedCornerShape(20.dp))
        )

        // .QUESTION TEXT.
        Text(
            currentQN?.question ?: "Unable to find question", modifier = Modifier
                .padding(horizontal = 20.dp)
                .padding(top = 10.dp), fontWeight = FontWeight.Bold, style = MaterialTheme.typography.h5)

        // .OPTIONS.
        if (showAnswer && selectedAnswer != (currentQN?.correct)) {
            Text("正确答案是什么呢？", color = Color.Red, modifier = Modifier.fillMaxWidth(), textAlign = TextAlign.Center)
        }

        options.forEach { option ->
            Box(Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
                Button(
                    onClick = {
                        if (!showAnswer) {
                            selectedAnswer = option
                        }
                        topic?.let {
                            viewModel.updateQuestionAnswer(
                                it.id,
                                currentQNindex,
                                option,
                                questionsSize
                            )
                        }
                    },
                    modifier = Modifier
                        .fillMaxWidth(0.9f)
                        .height(90.dp)
                        .padding(vertical = 15.dp),
                    colors = ButtonDefaults.buttonColors(
                        buttonColor(
                            option,
                            currentQN?.correct ?: "",
                            selectedAnswer,
                            showAnswer
                        )
                    ),
                    shape = RoundedCornerShape(10.dp),
                ) {
                    Text(
                        option,
                        textAlign = TextAlign.Center,
                        fontSize = 30.sp
                    )
                }
                Spacer(modifier = Modifier.height(12.dp)) // Spacer(Modifier.fillMaxSize(0.82f))
            }
        }

        // .NAVIGATION.
        Row (modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            // ..PREVIOUS..
            TextButton(
                onClick = {
                    if (canGoPrev) {
                        currentQNindex--
                        selectedAnswer = questions[currentQNindex].selected
                    }
                }, enabled = canGoPrev
            ) {
                Text("<", style = MaterialTheme.typography.h4)
            }
            Spacer(modifier = Modifier.weight(1f))

            // ..NEXT..
            TextButton(
                onClick = {
                    if (currentQNindex +1 >= questionsSize) {
                        val wrongNum = viewModel.countIncorrectAnswers(topicName)
                        val correctNum = questionsSize - wrongNum
                        navController.navigate("mcqresults/${topic!!.id}/$topicName/$wrongNum,$correctNum")

                    } else {
                        currentQNindex++
                        selectedAnswer = questions[currentQNindex].selected
                    }
                }, enabled = canGoNext
            ) {
                Text(">", style = MaterialTheme.typography.h4)
            }
        }
    }
}
