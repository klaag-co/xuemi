package com.example.xuemi.flashcards

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.absolutePadding
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.example.xuemi.MyViewModel
import com.example.xuemi.backButton

@Composable
fun Secondary(viewModel: MyViewModel, navController: NavController) {
    val showButton by viewModel.showButton.collectAsState()
    Column {
        backButton("Home") {
            navController.navigate("home")
        }
        title(viewModel = viewModel)
        chaptertemplate(viewModel, navController, "一","0")
        chaptertemplate(viewModel, navController,"二","1")
        chaptertemplate(viewModel, navController,"三","2")
        chaptertemplate(viewModel, navController,"四","3")
        chaptertemplate(viewModel, navController,"五","4")
        if (showButton) {
            chaptertemplate(viewModel, navController, "六","5")
        }
        Button(
            onClick = { },
            colors = ButtonDefaults.buttonColors(Color(194, 206, 217)),
            shape = RoundedCornerShape(20.dp),
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 25.dp, vertical = 7.dp)
        ) {
            Column {
                Text(
                    text = "EOY Practice",
                    color = Color.Black,
                    fontSize = 28.sp,
                    modifier = Modifier
                        .padding(horizontal = 5.dp, vertical = 7.dp)

                )
            }
        }

    }

}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun Chapter(viewModel: MyViewModel, navController: NavController) {
    val sheetstate = rememberModalBottomSheetState()
    var isSheetOpen: Boolean by rememberSaveable {
        mutableStateOf(false)
    }

    Column {
        Row (verticalAlignment = Alignment.CenterVertically){
            backButton("中${viewModel.getFromList(0)}") {
                navController.navigate("secondary")
            }
            Spacer(Modifier.fillMaxWidth(0.3f))
            Text("单元${viewModel.getFromList(1)}",
                fontSize = 19.sp,
                fontWeight = FontWeight.Bold,
            )
        }
        title(viewModel)
        topictemplate(viewModel, { isSheetOpen = true }, "一")
        topictemplate(viewModel, { isSheetOpen = true }, "二" )
        topictemplate(viewModel, { isSheetOpen = true }, "三")
    }
    if (isSheetOpen) {
        ModalBottomSheet(sheetState = sheetstate, onDismissRequest = { isSheetOpen = false }) {
            Topic(viewModel, navController)
        }
    }

}

@Composable
fun Topic(viewModel: MyViewModel, navController: NavController) {
    Column {
        Text(
            "习题",
            fontSize = 45.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(horizontal = 25.dp, vertical = 4.dp)
        )
        Spacer(modifier = Modifier.padding(5.dp))
        quiztemplate(viewModel, navController,"Handwriting")
        quiztemplate(viewModel, navController,"MCQ")
        quiztemplate(viewModel, navController,"Flashcards")
        Spacer(modifier = Modifier.padding(20.dp))
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@Composable
fun title(viewModel: MyViewModel) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .absolutePadding(bottom = 7.dp, right = 25.dp, left = 25.dp),
        colors = CardDefaults.cardColors(
            containerColor = Color(126, 190, 240),
            contentColor = Color.White
        )
    ) {
        Row {
            Text(
                text = "中${viewModel.getFromList(0)}",
                textAlign = TextAlign.Center,
                fontSize = 35.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 10.dp)
            )

        }
    }
}
@Composable
fun chaptertemplate(viewModel: MyViewModel, navController: NavController, chapter: String?, chapterNUM: String) {
    Button(
        onClick = {
            navController.navigate("chapter")
            viewModel.updateItem(2, chapterNUM)
            chapter?.let { viewModel.updateItem(1, it) }
        },
        colors = ButtonDefaults.buttonColors(Color(217, 217, 217)),
        shape = RoundedCornerShape(20.dp),
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 25.dp, vertical = 7.dp)
    ) {
        Column {
            Text(
                text = "单元$chapter",
                color = Color.Black,
                fontSize = 28.sp,
                modifier = Modifier
                    .padding(horizontal = 5.dp, vertical = 5.dp)

            )
        }
    }
}

@Composable
fun topictemplate(viewModel: MyViewModel, onButtonClick: () -> Unit, topic: String) {
    val dataFromJson = remember { viewModel.loadDataFromJson("中${viewModel.getFromList(0)}.json") }
    val chapterData = dataFromJson?.chapters?.getOrNull(viewModel.getFromList(2).toIntOrNull() ?: 0)?.topics

    val name: String? = when (topic) {
        "一" -> chapterData?.topic1?.name
        "二" -> chapterData?.topic2?.name
        "三" -> chapterData?.topic3?.name
        else -> ""
    }
    Button(
        onClick = { viewModel.updateItem(3, topic)
            onButtonClick()
        },
        colors = ButtonDefaults.buttonColors(Color(217, 217, 217)),
        shape = RoundedCornerShape(20.dp),
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 25.dp, vertical = 7.dp)
    ) {
        Column {
            Text(
                text = name.toString(),
                textAlign = TextAlign.Center,
                color = Color.Black,
                fontSize = 24.sp,
                lineHeight = 25.sp,
                modifier = Modifier
                    .padding(horizontal = 5.dp, vertical = 7.dp)
            )

        }
    }
}

@Composable
fun quiztemplate(viewModel: MyViewModel, navController: NavController, quiz: String) {
    Button(
        onClick = {
            viewModel.updateItem(4, "${quiz.first()}")
            navController.navigate(quiz.lowercase())
        },
        colors = ButtonDefaults.buttonColors(Color(217, 217, 217)),
        shape = RoundedCornerShape(20.dp),
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 25.dp, vertical = 7.dp)
    ) {
        Column {
            Text(
                text = quiz,
                color = Color.Black,
                fontSize = 28.sp,
                modifier = Modifier
                    .padding(horizontal = 5.dp, vertical = 7.dp)

            )
        }
    }
}

