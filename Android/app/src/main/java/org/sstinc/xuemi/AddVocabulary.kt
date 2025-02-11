package org.sstinc.xuemi

import android.annotation.SuppressLint
import android.util.Log
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.absolutePadding
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardColors
import androidx.compose.material3.Checkbox
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.awaitAll
import org.sstinc.xuemi.quiz.Word

@Composable
fun VocabSection(viewModel: MyViewModel, secondary: Int, sectionOfData: List<Word>, checked: (Word) -> Unit) {
    val cSecondary = when(secondary) {
        1 -> "一"
        2 -> "二"
        3 -> "三"
        4 -> "四"
        else -> "一"
    }
    Text("中$cSecondary", color = Color.Gray, modifier = Modifier
        .padding(15.dp)
        .absolutePadding(top = 20.dp, bottom = 5.dp))

    Column {
        sectionOfData.forEach { word ->
            vocabItem(viewModel, word)
        }
    }



}
@SuppressLint("UnusedMaterial3ScaffoldPaddingParameter")
@Composable
fun AddVocabulary (viewModel: MyViewModel) {
    val sectionedData = remember { mutableStateOf<List<List<Word>>>(emptyList()) }
    var tempFolder = remember { mutableStateListOf<Word>() }

    LaunchedEffect(Unit) {
        sectionedData.value = listOf(
            viewModel.selectJson(0),
            viewModel.selectJson(1),
            viewModel.selectJson(2),
            viewModel.selectJson(3)
        ).awaitAll()
    }
    Scaffold(
        topBar = {
            Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 10.dp, horizontal = 15.dp)) {
                Text(
                    "New Folder",
                    fontSize = 38.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding( vertical = 5.dp)
                )
                Button(onClick = {
                    Log.d("temp", tempFolder.joinToString(", "))
                } ) {
                    Text("Finish")
                }
            }
        }
    ) {

        LazyColumn(Modifier.padding(top = 60.dp, bottom = 90.dp)) {
            items(sectionedData.value.size) { index ->
                VocabSection(
                    viewModel,
                    (index + 1),
                    sectionOfData = sectionedData.value[index]
                ) { word ->
                    tempFolder.add(word)
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

    Text("enheeh", textAlign = TextAlign.Center
    )
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
                    if (checked == true) {
                        viewModel.addTempFolder(item)
                    }
                    Log.d("temp", "hoho ${_tempFolder}")

                },
                    modifier = Modifier.padding(3.dp))

            }
        }
    }
}

