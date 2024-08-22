package com.example.xuemi

import android.annotation.SuppressLint
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.absolutePadding
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.State
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.RectangleShape
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import androidx.room.Entity
import androidx.room.PrimaryKey


enum class NoteType {
    Exam, Note, 中一, 中二, 中三, 中四
}

@Entity
data class Note(
    @PrimaryKey (autoGenerate = true)
    val id: Int = 0,
    var type: NoteType,
    val title: String,
    val body: String
)

@Composable
fun groupedList(navController: NavController, header: String, sections: State<List<Note>?>, delete: String, viewModel: MyViewModel) {
    Spacer(modifier = Modifier.padding(bottom = 20.dp))
    Column {
        Text(
            text = header,
            modifier = Modifier.padding(horizontal = 30.dp),
            color = Color.Gray
        )

        sections.value?.forEach { note ->
            noteItem(navController = navController, viewModel = viewModel, item = note, delete = delete) {

            }


        }

    }

}
@Composable
fun Notes(viewModel: MyViewModel, navController: NavController) {
    val searchText = remember { mutableStateOf("") }
    val focusRequester = remember { FocusRequester() }
    val focusManager = LocalFocusManager.current

    val examNotes = viewModel.searchNotesByTitle(searchText.value, type = NoteType.Exam).observeAsState(emptyList())
    val notesNotes = viewModel.searchNotesByTitle(searchText.value, type = NoteType.Note).observeAsState(emptyList())
    val sec1 = viewModel.searchNotesByTitle(searchText.value, type = NoteType.中一).observeAsState(emptyList())
    val sec2 = viewModel.searchNotesByTitle(searchText.value, type = NoteType.中二).observeAsState(emptyList())
    val sec3 = viewModel.searchNotesByTitle(searchText.value, type = NoteType.中三).observeAsState(emptyList())
    val sec4 = viewModel.searchNotesByTitle(searchText.value, type = NoteType.中四).observeAsState(emptyList())


    var delete: String by rememberSaveable {
        mutableStateOf("Edit")
    }

    Box (modifier = Modifier
        .fillMaxSize()
        .pointerInput(Unit) { detectTapGestures(onTap = { focusManager.clearFocus() }) }
    ){
        Column {
            Row(
                modifier = Modifier
                    .padding(top = 10.dp)
                    .fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
            ) {
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
                    Text(
                        delete,
                        color = Color(70, 156, 253),
                        fontSize = 20.sp
                    )
                }
                Spacer(modifier = Modifier.fillMaxWidth(0.7f))

                TextButton(onClick = { navController.navigate("addnote") }) {
                    Text(
                        "＋",
                        color = Color(70, 156, 253),
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold,
                    )
                }
            }
            Text(
                "Notepad",
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

            LazyColumn (Modifier.padding(bottom = 100.dp)){
                item {
                    groupedList(navController, "EXAM", examNotes, delete, viewModel)
                    groupedList(navController, "NOTES", notesNotes, delete, viewModel)
                    groupedList(navController, "SECONDARY 1", sec1, delete, viewModel)
                    groupedList(navController, "SECONDARY 2", sec2, delete, viewModel)
                    groupedList(navController, "SECONDARY 3", sec3, delete, viewModel)
                    groupedList(navController, "SECONDARY 4", sec4, delete, viewModel)
                }
            }
        }
    }
}


@Composable
fun noteItem(navController: NavController, viewModel: MyViewModel, item: Note, delete: String, onDelete: ()-> Unit) {
    Row (Modifier.padding(horizontal = 17.dp)){
        if (delete == "Done") {
            IconButton(
                onClick = { viewModel.delete(item.id) }
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
                .fillMaxWidth()
                .padding(3.dp),
            colors = ButtonDefaults.buttonColors(Color(243, 242, 245)),

            ) {

            Text(
                text = item.title,
                fontSize = 20.sp,
                textAlign = TextAlign.Start,
                color = Color.Black,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 2.dp)
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

    Column (Modifier.absolutePadding(top = 15.dp)){
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
                    modifier = Modifier.fillMaxWidth()
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
//                        NoteType.entries.forEach { type ->
//                            DropdownMenuItem(
//                                text = { Text(type.name) },
//                                onClick = {
//                                    selectedType = type
//                                    expanded = false
//                                }
//                            )
//                        }
                        DropdownMenuItem(
                            text = { Text("Exam") },
                            onClick = {
                                selectedType = NoteType.Exam
                                expanded = false
                            }
                        )
                        DropdownMenuItem(
                            text = { Text("Note") },
                            onClick = {
                                selectedType = NoteType.Note
                                expanded = false
                            }
                        )
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
@SuppressLint("UnusedMaterial3ScaffoldPaddingParameter")
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun UpdateNote(navController: NavController, viewModel: MyViewModel, itemID: Int?) {
    val notes by viewModel.notesList.observeAsState()
    val item: Note? = notes?.find { it.id == itemID }
    var title by remember { mutableStateOf(item?.title ?: "") }
    var body by remember { mutableStateOf(item?.body ?: "") }


    Column {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = {},
                    navigationIcon = {
                        IconButton(onClick = { navController.popBackStack()
                            viewModel.update(title, body, item?.id ?: 0)
                        }) {
                            Icon(Icons.Filled.ArrowBack, contentDescription = "Back")
                        }

                    }
                )
            }
        ) {
            Column(
                Modifier.padding(
                    start = 20.dp,
                    end = 20.dp,
                    top = 10.dp,
                    bottom = 90.dp
                )
            ) {
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
                HorizontalDivider(Modifier.padding(horizontal = 10.dp))
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

    }
}





