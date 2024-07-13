package com.example.xuemi
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
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.State
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.room.Entity
import androidx.room.PrimaryKey

enum class BookmarkSection {
    中一, 中二, 中三, 中四
}
@Entity
data class Bookmark(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val type: BookmarkSection,
    val word: String,
    val chapter: String,
    val topic: String,
)

@Composable
fun dropdown(viewModel: MyViewModel, secondary: String, bookmarksList: State<List<Bookmark>>) {
    var expanded by remember { mutableStateOf(false) }
    Column(modifier = Modifier
        .fillMaxWidth()
        .padding(8.dp)) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(Color.LightGray)
                .padding(16.dp)
                .clickable { expanded = !expanded },
            contentAlignment = Alignment.CenterStart
        ) {
            Text(
                text = secondary,
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
            )
            Icon(
                imageVector = if (expanded) Icons.AutoMirrored.Filled.KeyboardArrowRight else Icons.Default.KeyboardArrowDown,
                contentDescription = null,
                modifier = Modifier.align(Alignment.CenterEnd)
            )
        }
        if (expanded) {
            LazyColumn {
                items(bookmarksList.value.size) { item ->
                    val bookmark = bookmarksList.value[item]
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(Color.Gray)
                            .padding(16.dp)
                            .clickable { /* Handle click */ },
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Column {
                            Text(text = bookmark.word, fontWeight = FontWeight.Bold)
                            Text("单元${bookmark.chapter} 第${bookmark.topic}课")
                        }
                        IconButton(onClick = { viewModel.deleteBookmark(bookmark.id) }) {

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
fun Bookmarks(viewModel: MyViewModel) {
    val searchText = remember { mutableStateOf("") }
    val focusRequester = remember { FocusRequester() }
    val focusManager = LocalFocusManager.current

    val sec1 = viewModel.searchBookmarksByTitle("", BookmarkSection.中一).observeAsState(emptyList())
    val sec2 = viewModel.searchBookmarksByTitle("", BookmarkSection.中二).observeAsState(emptyList())
    val sec3 = viewModel.searchBookmarksByTitle("", BookmarkSection.中三).observeAsState(emptyList())
    val sec4 = viewModel.searchBookmarksByTitle("", BookmarkSection.中四).observeAsState(emptyList())

    Column ( Modifier.pointerInput(Unit) { detectTapGestures(onTap = { focusManager.clearFocus() }) }
    ){
        Button(onClick = { viewModel.clearAllBookmarks() }) {
            Text("")
        }
        Text(
            "Bookmarks",
            fontWeight = FontWeight.Bold,
            fontSize = 40.sp,
            modifier = Modifier.padding(start = 17.dp, top = 6.dp)
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
                .padding(top = 10.dp)
                .fillMaxHeight(0.077f)
                .focusRequester(focusRequester)
        )

        dropdown(viewModel, secondary = "中一", bookmarksList = sec1)
        dropdown(viewModel, secondary = "中二", bookmarksList = sec2)
        dropdown(viewModel, secondary = "中三", bookmarksList = sec3)
        dropdown(viewModel, secondary = "中四", bookmarksList = sec4)
    }
}