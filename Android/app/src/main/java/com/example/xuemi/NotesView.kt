package com.example.xuemi
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.absolutePadding
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Divider
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.RectangleShape
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import androidx.room.Entity
import androidx.room.PrimaryKey


enum class NoteType {
    Exam, Note
}

@Entity
data class Note(
    @PrimaryKey(autoGenerate = true)
    var id: Int = 0,
    var type: NoteType,
    val title: String,
    val body: String
)

@Composable
fun groupedList(navController: NavController, header: String, sections: List<Note>, delete: String, viewModel: MyViewModel) {
    LazyColumn {
        item {
            Text(
                text = header,
                modifier = Modifier.padding(horizontal = 30.dp),
                color = Color.Gray
            )
        }
        itemsIndexed(sections){ _: Int, item: Note ->
            noteItem(navController = navController, item = item, delete= delete, onDelete = { viewModel.delete(item.id) }
            )
        }

    }

}
@Composable
fun Notes(viewModel: MyViewModel, navController: NavController) {
    val notes by viewModel.notesList.observeAsState()
    val examNotes = notes?.filter { it.type == NoteType.Exam }
    val notesNotes = notes?.filter { it.type == NoteType.Note }

    var delete: String by rememberSaveable {
        mutableStateOf("Edit")
    }

    Column {
        Row(modifier = Modifier.absolutePadding(top = 10.dp, left = 10.dp)) {
            TextButton(
                onClick = {
                delete = if (delete == "Edit") {
                    "Done"
                } else {
                    "Edit"
                }
            },
                modifier = Modifier.size(width = 76.dp, height = 50.dp)
            ) {
                Text(delete,
                    color = Color(70, 156,253),
                    fontSize = 20.sp)
            }
            Spacer(modifier = Modifier.padding(horizontal = 125.dp))

            TextButton( onClick = { navController.navigate("addnote") }) {
                Text("＋",
                    color = Color(70, 156,253),
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
        Text(
            "Notepad",
            fontWeight = FontWeight.Bold,
            fontSize = 40.sp,
            modifier = Modifier.absolutePadding(left = 17.dp, top = 6.dp)
        )
        Spacer(modifier = Modifier.padding(vertical = 5.dp))
        examNotes?.let { groupedList(navController = navController, header = "EXAM", it, delete, viewModel) }
        Spacer(modifier = Modifier.padding(vertical = 14.dp))
        notesNotes?.let { groupedList(navController = navController, header = "NOTES", it, delete, viewModel) }

    }
}


@Composable
fun noteItem(navController: NavController, item: Note, delete: String, onDelete: ()-> Unit) {
    Row (Modifier.padding(horizontal = 17.dp)){
        if (delete == "Done") {
            IconButton(
                onClick = { onDelete() }
            ) {
                Icon(
                    painter = painterResource(id = R.drawable.delete),
                    contentDescription = "delete",
                    tint = Color.Red
                )
            }
        }

        Button(
            onClick = { navController.navigate("update/${item.id}") },
            shape = RoundedCornerShape(10.dp),
            modifier = Modifier
                .fillMaxWidth(),
            colors = ButtonDefaults.buttonColors(Color(239, 238, 246)),

            ) {

            Text(
                text = item.title,
                fontSize = 20.sp,
                textAlign = TextAlign.Start,
                color = Color.Black,
                modifier = Modifier
                    .fillMaxWidth()
            )
        }
    }
}

@Composable
fun CreateNote(viewModel: MyViewModel, navController: NavController) {
    var title by remember { mutableStateOf("") }
    var body by remember { mutableStateOf("") }
    var expanded by remember { mutableStateOf(false) }
    var selectedType by remember { mutableStateOf(NoteType.Exam) }

    Column (Modifier.absolutePadding(15.dp)){
        Row {
            Spacer(modifier = Modifier.padding(horizontal = 145.dp))
            TextButton(
                onClick = {
                    viewModel.add(selectedType, title, body)
                    navController.navigate("notes")
                },
            ) {
                Text(
                    text = "Save",
                    color = Color(70, 156, 253),
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.End,
                    modifier = Modifier
                )
            }
        }
        Text(
            "New Note",
            fontSize = 38.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(horizontal = 23.dp)
        )
        TextField(
            value = title,
            onValueChange = { title = it },
            modifier = Modifier
                .fillMaxWidth()
                .padding(18.dp),
            placeholder = {Text("Title")},
            colors = TextFieldDefaults.colors(
                unfocusedContainerColor = Color(239, 238,246),
                unfocusedIndicatorColor = Color(239, 238,246),
                focusedContainerColor = Color(239, 238,246),
                focusedIndicatorColor = Color(204, 203, 212)
            )

        )

        Card(
            colors = CardDefaults.cardColors(Color(239, 238,246)),
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 18.dp),
            shape = RectangleShape
        ) {
            Row (verticalAlignment = Alignment.CenterVertically, modifier = Modifier.padding(horizontal = 15.dp, vertical = 20.dp)){
                Text(
                    "Note Type",
                    fontSize = 16.sp,
                )

                Spacer(Modifier.padding(horizontal = 92.dp))
                Box(modifier = Modifier
                    .fillMaxWidth()
                    .wrapContentSize(Alignment.TopStart)) {
                    Text("$selectedType ▼",
                        fontSize = 16.sp,
                        color = Color(73, 69, 79),
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable(onClick = { expanded = true })
                            .background(
                                Color(239, 238, 246)
                            ))
                    DropdownMenu(
                        expanded = expanded,
                        onDismissRequest = { expanded = false },
                        modifier = Modifier
                            .background(
                                Color(239, 238,246)
                            )

                    ) {
                        NoteType.entries.forEach { type ->
                            DropdownMenuItem(
                                text = { Text(type.name) },
                                onClick = {
                                    selectedType = type
                                    expanded = false
                                }
                            )
                        }
                    }
                }
            }


        }

        TextField(
            value = body,
            onValueChange = { body = it },
            modifier = Modifier
                .fillMaxWidth()
                .padding(18.dp),
            placeholder = {Text("Type something...")},
            colors = TextFieldDefaults.colors(
                unfocusedContainerColor = Color(239, 238,246),
                unfocusedIndicatorColor = Color(239, 238,246),
                focusedContainerColor = Color(239, 238,246),
                focusedIndicatorColor = Color(204, 203, 212)

            )

        )


    }
}
@Composable
fun UpdateNote(navController: NavController, viewModel: MyViewModel, itemID: Int?) {
    val notes by viewModel.notesList.observeAsState()
    val item: Note? = notes?.find { it.id == itemID }
    var title by remember { mutableStateOf(item?.title ?: "") }
    var body by remember { mutableStateOf(item?.body ?: "") }
    Column{
        TextButton(
            onClick = {
                viewModel.update(title, body, item?.id ?: 0)
                navController.navigate("notes")},
        ) {
            Text(
                text = "< Notepad",
                color = Color(70, 156, 253),
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                textAlign = TextAlign.End

            )
        }
        OutlinedTextField(
            value = title,
            onValueChange = { title = it },
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = Color.White,
                unfocusedBorderColor = Color.White,
            ),
            textStyle = TextStyle(
                fontWeight = FontWeight.ExtraBold,
                fontSize = 25.sp
            )
        )
        Divider(Modifier.padding(horizontal = 10.dp))
        OutlinedTextField(
            value = body,
            onValueChange = { body = it },
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = Color.White,
                unfocusedBorderColor = Color.White,
            )
        )

    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun Preview() {
}

