package org.sstinc.xuemi

import android.annotation.SuppressLint
import android.util.Log
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.Button
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.sstinc.xuemi.quiz.Word

@Composable
fun VocabSection(viewModel: MyViewModel, secondary: String, sectionOfData: List<Word>) {

    SectionHeader(title = "SECONDARY $secondary")
    Column {
        sectionOfData.forEach { word ->
            Text(word.word)

        }
    }



}
@SuppressLint("UnusedMaterial3ScaffoldPaddingParameter")
@Composable
fun AddVocabulary (viewModel: MyViewModel) {
    val sectionedData by viewModel.sectionedData.collectAsState(emptyList())
    Log.d("temp", sectionedData.toString())
    Scaffold(
        topBar = {
            Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 10.dp, horizontal = 15.dp)) {
                Text(
                    "Vocabulary List",
                    fontSize = 38.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding( vertical = 5.dp)
                )
                Button(onClick = {  } ) {
                    Text("Finish")
                }
            }
        }
    ) {
        LazyColumn(Modifier.padding(top = 20.dp)) {
            items(sectionedData.size) { index ->
                VocabSection(
                    viewModel,
                    (index + 1).toString(),
                    sectionOfData = sectionedData[index]
                )
            }

        }
    }

}