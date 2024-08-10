import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.LinearProgressIndicator
import androidx.compose.material.MaterialTheme
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.navigation.NavController
import com.example.xuemi.BookmarkSection
import com.example.xuemi.MyViewModel
import com.example.xuemi.R
import com.example.xuemi.backButton
import com.example.xuemi.quiz.Word
import com.google.accompanist.pager.ExperimentalPagerApi
import com.google.accompanist.pager.HorizontalPager
import com.google.accompanist.pager.rememberPagerState
import kotlinx.coroutines.launch

@OptIn(ExperimentalPagerApi::class)
@Composable
fun FlashcardScreen(
    viewModel: MyViewModel,
    navController: NavController,
    fromHome: String,
    secondary: String,
    chapter: String,
    chapter_: Int,
    topic: String
) {
    LaunchedEffect(Unit) {
        viewModel.loadData("中${viewModel.getFromList(0)}.json")
    }

    val dataFromJson by viewModel.loadedData.collectAsState()
    val pagerState = rememberPagerState()
    val chapterData = dataFromJson?.chapters?.getOrNull(chapter_)?.topics
    var wordDataSize by remember { mutableStateOf(0) }

    val wordList = when (topic) {
        "一" -> chapterData?.topic1?.topic
        "二" -> chapterData?.topic2?.topic
        "三" -> chapterData?.topic3?.topic
        else -> emptyList()
    }
    val wordName = when (topic) {
        "一" -> chapterData?.topic1?.name
        "二" -> chapterData?.topic2?.name
        "三" -> chapterData?.topic3?.name
        else -> ""
    }

    wordDataSize = wordList?.size ?: 0

    Column(Modifier.padding(16.dp)) {
        if (fromHome == "home") {
            backButton("Home") {
                navController.navigate("home")
            }
        } else if (fromHome == "bookmarks") {
            backButton("Bookmarks") {
                navController.navigate("bookmarks")
            }
        } else {
            backButton("单元$chapter") {
                navController.navigate("chapter")
            }
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
            state = pagerState
        ) { page ->

            val wordData = wordList?.getOrNull(page)

            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                // Get topic
                if (wordData != null) {
                    Flashcard(
                        wordSets = wordData,
                        viewModel = viewModel,
                        secondary = secondary,
                        chapter = chapter,
                        topic = wordName.toString()
                    )
                    Spacer(Modifier.padding(30.dp))
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
    val context = LocalContext.current
    var showHanziWriter by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()

    LaunchedEffect(Unit) {
        viewModel.loadBookmarks()
        viewModel.loadBookmarkNames()
    }

    val bookmarkNames by viewModel.bookmarkWords.observeAsState(emptyList())
    val bookmarkList by viewModel.bookmarksList.observeAsState(emptyList())

    val bookmarkInside = bookmarkNames.contains(wordSets.word)

    Card(
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
        modifier = Modifier
            .fillMaxWidth(0.8f)
            .fillMaxHeight(0.67f),
        shape = RoundedCornerShape(30.dp),
        colors = CardDefaults.cardColors(
            containerColor = Color(219, 238, 255),
        )
    ) {
        Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {

            LazyColumn(
                modifier = Modifier
                    .padding(bottom = 45.dp, top = 1.dp)
                    .fillMaxWidth(0.79f),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {

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
                    Text(
                        wordSets.word,
                        textAlign = TextAlign.Center,
                        style = MaterialTheme.typography.h2,
                        modifier = Modifier
                            .clickable {
                                scope.launch {
                                    showHanziWriter = true
                                }
                            }
                            .padding(16.dp)
                    )
                    Text(
                        wordSets.pinyin,
                        textAlign = TextAlign.Center,
                        style = MaterialTheme.typography.h4
                    )
                    Text(
                        wordSets.chineseDefinition,
                        textAlign = TextAlign.Center,
                        style = MaterialTheme.typography.h4,
                        modifier = Modifier.padding(vertical = 10.dp)
                    )
                    Text(
                        wordSets.englishDefinition,
                        textAlign = TextAlign.Center,
                        style = MaterialTheme.typography.h5
                    )
                }
            }
        }
    }

    Box(
        Modifier
            .fillMaxSize()
            .padding(top = 18.dp, bottom = 20.dp, end = 17.dp), contentAlignment = Alignment.TopEnd
    ) {
        IconButton(
            onClick = {
                if (bookmarkInside) {
                    val bookmarkToDelete = bookmarkList.find { it.word == wordSets.word }
                    bookmarkToDelete?.let { viewModel.deleteBookmark(it.id) }
                } else {
                    viewModel.addBookmark(
                        BookmarkSection.valueOf("中${viewModel.flashcardGetFromList(0)}"),
                        wordSets.word,
                        viewModel.flashcardGetFromList(1),
                        viewModel.flashcardGetFromList(3)
                    )
                }
                viewModel.loadBookmarkNames()
            }
        ) {
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

    if (showHanziWriter) {
        HanziWriterWebView(character = wordSets.word)
    }
}

@Composable
fun HanziWriterWebView(character: String) {
    Box(modifier = Modifier.fillMaxSize()) {
        AndroidView(factory = { context ->
            WebView(context).apply {
                settings.javaScriptEnabled = true
                webViewClient = WebViewClient()

                loadUrl("file:///android_asset/hanzi_writer.html")

                evaluateJavascript("loadHanziCharacter('$character')", null)
            }
        })
    }
}
