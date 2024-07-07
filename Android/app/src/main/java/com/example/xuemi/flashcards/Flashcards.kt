package com.example.xuemi.flashcards

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.MaterialTheme
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.example.xuemi.MyViewModel


@Composable
fun FlashcardScreen(viewModel: MyViewModel, navController: NavController) {
    val currentSet by rememberSaveable { mutableStateOf(0) } ///// change based on currentstate
    val dataFromJson = remember { viewModel.loadDataFromJson() }

    val chapterIndex = viewModel.getFromList(2).toIntOrNull()
    val chapterData = dataFromJson?.chapters?.getOrNull(chapterIndex ?: 0)?.topics
    var wordData = chapterData?.topic1?.getOrNull(1)

    // get topic
    if (chapterData != null) {
        if (viewModel.getFromList(3) == "一") {
            wordData = chapterData.topic1.getOrNull(currentSet)
        } else if (viewModel.getFromList(3) == "二") {
            wordData = chapterData.topic2.getOrNull(currentSet)
        } else if (viewModel.getFromList(3) == "三") {
            wordData = chapterData.topic3.getOrNull(currentSet)
        }
        if (wordData != null) {
            Flashcard(wordData, viewModel)
            Button(onClick = { navController.navigate("home") }) {
                Text("Home")
            }
        } else {
            Text("No word data available.")
        }
    } else {
        Text("Loading data or invalid chapter index")
    }
}

@Composable
fun Flashcard(wordSets: Word, viewModel: MyViewModel) {
    Card (elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),modifier = Modifier
        .fillMaxWidth(0.9f)
        .fillMaxHeight(0.76f), shape = RoundedCornerShape(30.dp)
    ){
        Box (Modifier.fillMaxSize(), contentAlignment = Alignment.Center){
            Column(modifier = Modifier
                .padding(10.dp)
                .fillMaxWidth(0.75f), horizontalAlignment = Alignment.CenterHorizontally) {
//                Row (verticalAlignment = Alignment.CenterVertically){
//                    IconButton(
//                        onClick = { /*TODO*/ }
//                    ) {
//                        Icon(
//                            painter = painterResource(id = R.drawable.o_bookmark),
//                            contentDescription = "bookmark?"
//                        )
//                    }
//                }
                Text("中${viewModel.getFromList(0)}:单元${viewModel.getFromList(1)}    topic-${viewModel.getFromList(3)}", style = MaterialTheme.typography.h5)
                Text(wordSets.word, textAlign = TextAlign.Center, style = MaterialTheme.typography.h2)
                Text(wordSets.pinyin, textAlign = TextAlign.Center, style = MaterialTheme.typography.h4)
                Text(wordSets.chineseDefinition, textAlign = TextAlign.Center, style = MaterialTheme.typography.h4, modifier = Modifier.padding(vertical = 10.dp))
                Text(wordSets.englishDefinition, textAlign = TextAlign.Center, style = MaterialTheme.typography.h5)
            }
        }
    }
}

