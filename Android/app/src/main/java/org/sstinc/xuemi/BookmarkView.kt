package org.sstinc.xuemi


import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.MaterialTheme
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import androidx.room.Entity
import androidx.room.PrimaryKey


enum class BookmarkSection {
    中一, 中二, 中三, 中四
}
@Entity
data class Bookmark(
    @PrimaryKey(autoGenerate = true)
    val id: Int = 0,
    val type: BookmarkSection,
    val word: String,
    val chapter: String,
    val topic: String,
    val leftOff: Int
)

@Composable
fun dropdown(
    viewModel: MyViewModel,
    navController: NavController,
    secondary: String,
    bookmarksList: List<Bookmark>,
    isFocused: Boolean
) {
    var expanded by remember { mutableStateOf(false) }

    // Column to contain the dropdown header and the expanded list
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 10.dp, horizontal = 20.dp)
    ) {
        // Box for the dropdown header
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(Color(227, 227, 227))
                .clickable { expanded = !expanded } // Clickable modifier on the Box
                .padding(19.dp),
            contentAlignment = Alignment.CenterStart,
        ) {
            Text(
                text = secondary,
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
            )
            Icon(
                imageVector =
                if (expanded && bookmarksList.isNotEmpty()) {
                    Icons.Default.KeyboardArrowDown
                } else {
                    Icons.AutoMirrored.Filled.KeyboardArrowRight
                },
                contentDescription = null,
                modifier = Modifier.align(Alignment.CenterEnd)
            )
        }

        // Expand the list of bookmarks if the dropdown is expanded
        if (isFocused) {
            expanded = true
        }
        if (expanded) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color(227, 227, 227)) // Ensure background covers full width
            ) {
                bookmarksList.forEach { bookmark ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(Color.LightGray)
                            .clickable {
                                val chapter_ = when (bookmark.chapter) {
                                    "一" -> 0
                                    "二" -> 1
                                    "三" -> 2
                                    "四" -> 3
                                    "五" -> 4
                                    "六" -> 5
                                    else -> 0
                                }
                                navController.navigate("flashcards/${secondary}/${bookmark.chapter}/${chapter_}/${bookmark.topic}/${bookmark.leftOff}.bookmarks")
                            }
                            .padding(19.dp),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Column {
                            Text(
                                text = bookmark.word,
                                fontWeight = FontWeight.Bold,
                                style = MaterialTheme.typography.body1
                            )
                            Text(
                                "单元${bookmark.chapter} 第${bookmark.topic}课",
                                style = MaterialTheme.typography.body1
                            )
                        }
                        IconButton(onClick = {
                            viewModel.deleteBookmark(bookmark.id)
                            viewModel.loadBookmarks()
                        }) {
                            Icon(
                                painter = painterResource(id = R.drawable.bookmark),
                                contentDescription = null
                            )
                        }
                    }
                }
            }
        }
    }
}



@Composable
fun Bookmarks(viewModel: MyViewModel, navController: NavController) {
    var searchText = remember { mutableStateOf("") }
    val focusRequester = remember { FocusRequester() }
    val focusManager = LocalFocusManager.current
    var isFocused by remember { mutableStateOf(false) }


    val sec1 by viewModel.searchBookmarksByTitle(searchText.value, BookmarkSection.中一).observeAsState(emptyList())
    val sec2 by viewModel.searchBookmarksByTitle(searchText.value, BookmarkSection.中二).observeAsState(emptyList())
    val sec3 by viewModel.searchBookmarksByTitle(searchText.value, BookmarkSection.中三).observeAsState(emptyList())
    val sec4 by viewModel.searchBookmarksByTitle(searchText.value, BookmarkSection.中四).observeAsState(emptyList())

    Column ( Modifier.pointerInput(Unit) { detectTapGestures(onTap = {
        focusManager.clearFocus()
    }) }
    ) {
        Text(
            "Bookmarks",
            fontWeight = FontWeight.Bold,
            fontSize = 40.sp,
            modifier = Modifier.padding(start = 17.dp, top = 12.dp)
        )
        TextField(
            searchText.value,
            { searchText.value = it },
            shape = RoundedCornerShape(15.dp),
            colors = TextFieldDefaults.colors(
                unfocusedContainerColor = Color(239, 238, 246),
                unfocusedIndicatorColor = Color(239, 238, 246),
                focusedContainerColor = Color(239, 238, 246),
                focusedIndicatorColor = Color(239, 238, 246)
            ),

            leadingIcon = {
                Icon(
                    painter = painterResource(id = R.drawable.search),
                    contentDescription = "search",
                )
            },
            placeholder = {
                Text("Search") /// Modifier.padding(start = 3.dp, bottom = 1.dp)
            },
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 15.dp)
                .padding(top = 10.dp, bottom = 10.dp)
                .fillMaxHeight(0.077f)
                .focusRequester(focusRequester)
                .onFocusChanged { focusState ->
                    isFocused = focusState.isFocused
                }
        )
        LazyColumn(Modifier.padding(bottom = 100.dp)) {
            item {
                dropdown(viewModel, navController, secondary = "一", bookmarksList = sec1, isFocused = isFocused)
                dropdown(viewModel, navController, secondary = "二", bookmarksList = sec2, isFocused = isFocused)
                dropdown(viewModel, navController, secondary = "三", bookmarksList = sec3, isFocused = isFocused)
                dropdown(viewModel, navController, secondary = "四", bookmarksList = sec4, isFocused = isFocused)
            }
        }
    }

}