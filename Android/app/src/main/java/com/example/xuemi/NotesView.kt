package com.example.xuemi
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.absolutePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.tooling.preview.PreviewParameter
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.forEach

data class Section(val title: String, val body: String)

@Composable
fun GroupedList(header: String, sections: Section, ) {


    LazyColumn {
        item {
            Text(header)
        }
        items(1) { fruit ->
            noteItem(sections.title)
        }


    }
}
@Composable
fun Notes(viewModel: MyViewModel) {
    val examNotes by viewModel.examNotes.collectAsState()
    Column {
        Row(modifier = Modifier.absolutePadding(top = 10.dp, left = 5.dp)) {
            TextButton( onClick = {/*TODO*/}) {
                Text("Edit",
                    color = Color(70, 156,253),
                    fontSize = 20.sp)
            }
            Spacer(modifier = Modifier.padding(horizontal = 120.dp))
            TextButton( onClick = {/*TODO*/}) {
                Text("＋",
                    color = Color(70, 156,253),
                    fontSize = 20.sp)
            }
        }
        Text(
            "Notepad",
            fontSize = 45.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding( horizontal = 15.dp)
        )
        GroupedList(header = "Exam", sections = examNotes)

    }
}


@Composable
fun noteItem(item: String) {
    Text(
        text = item,
        modifier = Modifier.padding(horizontal = 20.dp)
    )
}