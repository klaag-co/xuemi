package com.example.xuemi.quiz

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.LinearProgressIndicator
import androidx.compose.material.MaterialTheme
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.example.xuemi.BookmarkSection
import com.example.xuemi.MyViewModel
import com.example.xuemi.R
import com.example.xuemi.backButton
import com.google.accompanist.pager.ExperimentalPagerApi
import com.google.accompanist.pager.HorizontalPager
import com.google.accompanist.pager.rememberPagerState


@OptIn(ExperimentalPagerApi::class)
@Composable
fun FlashcardScreen(viewModel: MyViewModel, navController: NavController) {
    val dataFromJson = remember { viewModel.loadDataFromJson("中${viewModel.getFromList(0)}.json") }
    val pagerState = rememberPagerState()
    val chapterData = dataFromJson?.chapters?.getOrNull(viewModel.getFromList(2).toInt())?.topics
    var wordDataSize by remember { mutableIntStateOf(0) }

    val wordList = when (viewModel.getFromList(3)) {
        "一" -> chapterData?.topic1?.topic
        "二" -> chapterData?.topic2?.topic
        "三" -> chapterData?.topic3?.topic
        else -> emptyList()
    }
    val wordName = when (viewModel.getFromList(3)) {
        "一" -> chapterData?.topic1?.name
        "二" -> chapterData?.topic2?.name
        "三" -> chapterData?.topic3?.name
        else -> ""
    }

    wordDataSize = wordList?.size ?: 0

    Column (Modifier.padding(16.dp)){

        backButton("单元${viewModel.getFromList(1)}") {
            navController.navigate("chapter")
        }
        LinearProgressIndicator(
            progress = pagerState.currentPage.toFloat() / (wordDataSize - 1),
            color = Color(0xFF7EBDF0),
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.06f)
                .padding(vertical = 15.dp, horizontal = 20.dp)
                .clip(RoundedCornerShape(20.dp))
        )



        HorizontalPager(
            count = wordDataSize,
            state = pagerState,) {page->

            val wordData = wordList?.getOrNull(page)

            Box(Modifier.fillMaxSize(),contentAlignment = Alignment.Center) {
                // get topic

                if (wordData != null) {
                    Column {
                        Flashcard(wordData, viewModel, viewModel.getFromList(0), viewModel.getFromList(1),
                            wordName.toString()
                        )
                        Spacer(Modifier.padding(30.dp))
                    }

                } else {
                    Text("No word data available.")
                }
            }
        }
        Spacer(Modifier.fillMaxHeight(0.5f))
    }

}

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun Flashcard(wordSets: Word, viewModel: MyViewModel, secondary: String, chapter: String, topic: String) {
    LaunchedEffect(Unit) {
        viewModel.loadBookmarks()
        viewModel.loadBookmarkNames()
    }

    val bookmarkNames by viewModel.bookmarkWords.observeAsState(emptyList())
    val bookmarkList by viewModel.bookmarksList.observeAsState(emptyList())

    val bookmarkInside = bookmarkNames.contains(wordSets.word)



    Card (
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
        modifier = Modifier
            .fillMaxWidth(0.8f)
            .fillMaxHeight(0.67f), shape = RoundedCornerShape(30.dp),
        colors = CardDefaults.cardColors(
            containerColor = Color(219, 238, 255),
        )

    ){
        Box( Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {


            LazyColumn(modifier = Modifier
                .padding(bottom = 45.dp, top = 1.dp)
                .fillMaxWidth(0.79f), horizontalAlignment = Alignment.CenterHorizontally)
            {

                stickyHeader {
                    Text(
                        "中$secondary: 单元$chapter", style = MaterialTheme.typography.h6,
                        textAlign = TextAlign.Center,
                        modifier = Modifier
                            .background(color = Color(219, 238, 255))
                            .fillMaxWidth()
                            .padding(vertical = 12.dp)

                    )
                }
                item {
                    Text(wordSets.word, textAlign = TextAlign.Center, style = MaterialTheme.typography.h2)
                    Text(wordSets.pinyin, textAlign = TextAlign.Center, style = MaterialTheme.typography.h4)
                    Text(wordSets.chineseDefinition, textAlign = TextAlign.Center, style = MaterialTheme.typography.h4, modifier = Modifier.padding(vertical = 10.dp))
                    Text(wordSets.englishDefinition, textAlign = TextAlign.Center, style = MaterialTheme.typography.h5)
                }
            }
            Box (
                Modifier
                    .fillMaxSize()
                    .padding(top = 18.dp, bottom = 20.dp, end = 17.dp), contentAlignment = Alignment.TopEnd){
                IconButton(
                    onClick = {
                        if (bookmarkInside) {
                            val bookmarkToDelete = bookmarkList.find { it.word == wordSets.word }
                            bookmarkToDelete?.let { viewModel.deleteBookmark(it.id) }


                        } else {
                            viewModel.addBookmark(
                                BookmarkSection.valueOf("中${viewModel.getFromList(0)}"),
                                wordSets.word,
                                viewModel.getFromList(1),
                                viewModel.getFromList(3)
                            )

                        }
                        viewModel.loadBookmarkNames()
                    }
                )
                {
                    Icon(
                        painter = painterResource(id =
                        if (bookmarkInside) {
                            R.drawable.bookmark
                        } else {
                            R.drawable.o_bookmark
                        }
                        ),
                        contentDescription = "bookmark?",
                        modifier = Modifier.size(39.dp)
                    )
                }
            }
        }
    }
}
