package com.example.xuemi.flashcards

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.LinearProgressIndicator
import androidx.compose.material.MaterialTheme
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.example.xuemi.MyViewModel
import com.google.accompanist.pager.ExperimentalPagerApi
import com.google.accompanist.pager.HorizontalPager
import com.google.accompanist.pager.rememberPagerState


@OptIn(ExperimentalFoundationApi::class, ExperimentalPagerApi::class)
@Composable
fun FlashcardScreen(viewModel: MyViewModel, secondary: String) {
    val dataFromJson = remember { viewModel.loadDataFromJson("${secondary}.json") }
    val pagerState = rememberPagerState()
    var card by remember { mutableStateOf(0) }

    val chapterIndex = viewModel.getFromList(2).toIntOrNull()
    val chapterData = dataFromJson?.chapters?.getOrNull(chapterIndex ?: 0)?.topics
    var wordData = chapterData?.topic1?.getOrNull(1)
    var wordDataSize = chapterData!!.topic1.size

    Column {
        if (viewModel.getFromList(3) == "一") {
            wordData = chapterData.topic1.getOrNull(pagerState.currentPage)
            wordDataSize = chapterData.topic1.size
        } else if (viewModel.getFromList(3) == "二") {
            wordData = chapterData.topic2.getOrNull(pagerState.currentPage)
            wordDataSize = chapterData.topic2.size
        } else if (viewModel.getFromList(3) == "三") {
            wordData = chapterData.topic3.getOrNull(pagerState.currentPage)
            wordDataSize = chapterData.topic3.size
        }
        LinearProgressIndicator(
            progress = pagerState.currentPage.toFloat() / (wordDataSize - 1),
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        )

        HorizontalPager(count = wordDataSize, state = pagerState) {

            Text(wordDataSize.toString())

            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                // get topic

                if (wordData != null) {
                    Flashcard(wordData!!, viewModel)
                } else {
                    Text("No word data available.")
                }
            }
        }
    }

}

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun Flashcard(wordSets: Word, viewModel: MyViewModel) {
    Card (
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
        modifier = Modifier
            .fillMaxWidth(0.8f)
            .fillMaxHeight(0.67f), shape = RoundedCornerShape(30.dp),
        colors = CardDefaults.cardColors(
            containerColor = Color(219, 238, 255),
        )

    ){
        Box (Modifier.fillMaxSize(), contentAlignment = Alignment.Center){
            LazyColumn(modifier = Modifier
                .padding(vertical = 65.dp)
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
                stickyHeader {
                    Text(
                        "中${viewModel.getFromList(0)}:单元${viewModel.getFromList(1)}", style = MaterialTheme.typography.h5,
                        textAlign = TextAlign.Center,
                        modifier = Modifier
                            .background(color = Color(219, 238, 255))
                            .fillMaxWidth()
                            .padding(vertical = 10.dp)

                    )
                }
                item { }
                items(1) {
                    Text(wordSets.word, textAlign = TextAlign.Center, style = MaterialTheme.typography.h2)
                    Text(wordSets.pinyin, textAlign = TextAlign.Center, style = MaterialTheme.typography.h4)
                    Text(wordSets.chineseDefinition, textAlign = TextAlign.Center, style = MaterialTheme.typography.h4, modifier = Modifier.padding(vertical = 10.dp))
                    Text(wordSets.englishDefinition, textAlign = TextAlign.Center, style = MaterialTheme.typography.h5)
                }
            }
        }
    }
}

