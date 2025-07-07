package org.sstinc.xuemi

import android.annotation.SuppressLint
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardColors
import androidx.compose.material3.Checkbox
import androidx.compose.material3.Icon
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import org.sstinc.xuemi.db.Afolder
import org.sstinc.xuemi.quiz.Word

data class SectionedWord(val word: Word, val section: String)

//@Composable
//fun VocabSection(viewModel: MyViewModel, secondary: Int, sectionOfData: List<Word>, checked: (Word) -> Unit) {
//    val cSecondary = when(secondary) {
//        1 -> "一"
//        2 -> "二"
//        3 -> "三"
//        4 -> "四"
//        else -> "一"
//    }
//    Text("中$cSecondary", color = Color.Gray, modifier = Modifier
//        .padding(15.dp)
//        .absolutePadding(top = 20.dp, bottom = 5.dp))
//
//    LazyColumn {
//        item {
//            sectionOfData.forEach { word ->
//                vocabItem(viewModel, word)
//            }
//        }
//
//    }
//
//
//
//}
@OptIn(ExperimentalFoundationApi::class)
@SuppressLint("UnusedMaterial3ScaffoldPaddingParameter")
@Composable
fun AddVocabulary (viewModel: MyViewModel, navController: NavController) {
    val _tempFolder by viewModel.tempFolder.collectAsState()
    val grouped by viewModel.groupedSectionedWords.collectAsState()
    var name by remember { mutableStateOf("") }
    var show by remember { mutableStateOf(false) }

    val focusRequester = remember { FocusRequester() }
    val focusManager = LocalFocusManager.current
    var isFocused by remember { mutableStateOf(false) }


    val searchText by viewModel.searchText.collectAsState()

    if (show) {
        AlertDialog(
            onDismissRequest = {
                name = ""
                show = false },
            title = { Text("Enter Folder Name") },
            text = {
                TextField(
                    value = name,
                    onValueChange = { name = it },
                    placeholder = { Text("Enter Folder Name") }
                )

            },
            confirmButton = {
                Button(onClick = {
                    if (name != "" && _tempFolder.isNotEmpty()) {
                        viewModel.addFolder(Afolder(name = name, items = _tempFolder))
                        navController.popBackStack()
                        show = false
                    }
                }) {
                    Text("Confirm")
                }

            },
        )
    }
    Scaffold(
        floatingActionButton = {
            Button(onClick = {
                show = true
            }, modifier = Modifier.padding(vertical = 80.dp, horizontal = 10.dp)) {
                Text("Finish")
            }
        }
    ) {
        Column (
            Modifier.pointerInput(Unit) { detectTapGestures(onTap = {
                focusManager.clearFocus()
            }) }
        ) {
            Text(
                "New Folder",
                fontWeight = FontWeight.Bold,
                fontSize = 40.sp,
                modifier = Modifier.padding(start = 17.dp, top = 12.dp, bottom = 20.dp)
            )
            TextField(
                searchText,
                {
                    viewModel.updateSearchText(it)
                },
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
//                .focusRequester(focusRequester)
//                .onFocusChanged { focusState ->
//                    isFocused = focusState.isFocused
//                }
            )
            LazyColumn {
                grouped.forEach { (section, words) ->
                    stickyHeader {
                        Text(
                            section, color = Color.Gray, modifier = Modifier.padding(horizontal = 15.dp)
                        )
                    }
                    items(words) { wordItem ->
                        vocabItem(viewModel, wordItem.word)
                    }
                }
            }
        }
    }
}


@Composable
fun vocabItem(viewModel: MyViewModel, item: Word) {
    var checked by remember { mutableStateOf(false) }
    val _tempFolder by viewModel.tempFolder.collectAsState()
    var tempFolder by remember { mutableStateOf(_tempFolder) }

    Column {

        Row (Modifier.padding(horizontal = 10.dp, vertical = 5.dp)){
            Card(
                shape = RoundedCornerShape(10.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(3.dp),
                colors = CardColors(containerColor = Color(243, 242, 245), contentColor = Color.Black, disabledContainerColor = Color(243, 242, 245), disabledContentColor = Color.Black),


                ) {
                Row (Modifier.padding(horizontal = 17.dp)){
                    Text(
                        text = item.word,
                        fontSize = 20.sp,
                        textAlign = TextAlign.Start,
                        color = Color.Black,
                        modifier = Modifier
                            .fillMaxWidth(0.95f)
                            .padding(vertical = 10.dp)
                    )
                    // use tempfolder
                    Checkbox(checked = checked, onCheckedChange = {
                        checked = it
                        if (checked) {
                            viewModel.addTempFolder(item)
                        }

                    },
                        modifier = Modifier.padding(3.dp))

                }
            }
        }
    }

}

