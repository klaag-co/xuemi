package org.sstinc.xuemi

import android.annotation.SuppressLint
import android.util.Log
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
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
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
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
fun AddVocabulary (viewModel: MyViewModel) {
    val _tempFolder by viewModel.tempFolder.collectAsState()
    val grouped by viewModel.groupedSectionedWords.collectAsState()
    var name by remember { mutableStateOf("") }
    var show by remember { mutableStateOf(false) }
    if (show) {
        AlertDialog(
            onDismissRequest = { show = false },
            title = { Text("Save Folder") },
            text = {
                TextField(
                    value = name,
                    onValueChange = { name = it },
                    placeholder = { Text("Enter folder name here") }
                )

            },
            confirmButton = {
                Button(onClick = {
                    viewModel.addFolder(Afolder(name = name, items = _tempFolder))
                    show = false
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
                Log.d("temp", _tempFolder.count().toString())
            }, modifier = Modifier.padding(vertical = 80.dp, horizontal = 10.dp)) {
                Text("Finish")
            }
        }
    ) {
        Column (
        ) {
            Text(
                "New Folder",
                fontWeight = FontWeight.Bold,
                fontSize = 40.sp,
                modifier = Modifier.padding(start = 17.dp, top = 12.dp, bottom = 20.dp)
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

