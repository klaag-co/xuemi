@file:OptIn(ExperimentalMaterial3Api::class)

package com.example.xuemi

import android.adservices.topics.Topic
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
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.example.xuemi.ui.theme.XuemiTheme

@Composable
fun Secondary(viewModel: MyViewModel, navController: NavController) {
    val showButton by viewModel.showButton.collectAsState()
    Column {
        title(viewModel = viewModel)
        chaptertemplate(viewModel, navController, "1")
        chaptertemplate(viewModel, navController,"2")
        chaptertemplate(viewModel, navController,"3")
        chaptertemplate(viewModel, navController,"4")
        chaptertemplate(viewModel, navController,"5")
        if (showButton) {
            chaptertemplate(viewModel, navController, "6")
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

@Composable
fun Chapter(viewModel: MyViewModel, navController: NavController) {
    val sheetstate = rememberModalBottomSheetState()
    var isSheetOpen: Boolean by rememberSaveable {
        mutableStateOf(false)
    }
    var topicNum: String by rememberSaveable {
        mutableStateOf("1")
    }
    Column {
        title(viewModel)
        topictemplate(viewModel,  { isSheetOpen = true}, {topicNum = "1"}, "1" )
        topictemplate(viewModel,  { isSheetOpen = true }, {topicNum = "2"}, "2")
        topictemplate(viewModel,  { isSheetOpen = true }, {topicNum = "3"}, "3")

    }
    if (isSheetOpen) {
        ModalBottomSheet(sheetState = sheetstate, onDismissRequest = { isSheetOpen = false }) {
            Topic(viewModel, topicNum)
        }
    }

}

@Composable
fun Topic(viewModel: MyViewModel, topic: String?) {
    Column {
        Text(
            "Topic $topic",
            fontSize = 45.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(horizontal = 25.dp, vertical = 4.dp)
        )
        Spacer(modifier = Modifier.padding(5.dp))
        quiztemplate(viewModel, "Handwriting")
        quiztemplate(viewModel, "MCQ")
        quiztemplate(viewModel, "Flashcards")
        Spacer(modifier = Modifier.padding(20.dp))
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@Composable
fun title(viewModel: MyViewModel) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .absolutePadding(top = 20.dp, bottom = 7.dp, right = 25.dp, left = 25.dp),
        colors = CardDefaults.cardColors(
            containerColor = Color(126, 190, 240),
            contentColor = Color.White
        )
    ) {
        Row {
            Text(
                text = "Secondary ${viewModel.getFromList(0)}",
                textAlign = TextAlign.Center,
                fontSize = 35.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.absolutePadding(
                    top = 15.dp,
                    bottom = 15.dp,
                    right = 10.dp,
                    left = 70.dp
                )
            )

        }
    }
}

@Composable
fun quiztemplate(viewModel: MyViewModel, quiz: String?) {
    Button(
        onClick = { viewModel.updateItem(3, "${quiz?.first()}")
                  },
        colors = ButtonDefaults.buttonColors(Color(217, 217, 217)),
        shape = RoundedCornerShape(20.dp),
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 25.dp, vertical = 7.dp)
    ) {
        Column {
            Text(
                text = "$quiz",
                color = Color.Black,
                fontSize = 28.sp,
                modifier = Modifier
                    .padding(horizontal = 5.dp, vertical = 7.dp)

            )
        }
    }
}
@Composable
fun chaptertemplate(viewModel: MyViewModel, navController: NavController, chapter: String?) {
    Button(
        onClick = {
            navController.navigate("chapter")
            viewModel.updateItem(1, "$chapter") },
        colors = ButtonDefaults.buttonColors(Color(217, 217, 217)),
        shape = RoundedCornerShape(20.dp),
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 25.dp, vertical = 7.dp)
    ) {
        Column {
            Text(
                text = "Chapter $chapter",
                color = Color.Black,
                fontSize = 28.sp,
                modifier = Modifier
                    .padding(horizontal = 5.dp, vertical = 7.dp)

            )
        }
    }
}
@Composable
fun topictemplate(viewModel: MyViewModel, onButtonClick: () -> Unit, topicFun: () -> Unit, topic: String?) {
    Button(
        onClick = { viewModel.updateItem(2, "$topic")
                    onButtonClick()
                    topicFun()
                  },
        colors = ButtonDefaults.buttonColors(Color(217, 217, 217)),
        shape = RoundedCornerShape(20.dp),
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 25.dp, vertical = 7.dp)
    ) {
        Column {
            Text(
                text = "Topic $topic",
                color = Color.Black,
                fontSize = 28.sp,
                modifier = Modifier
                    .padding(horizontal = 5.dp, vertical = 7.dp)

            )
        }
    }
}


@Preview(showSystemUi = true)
@Composable
fun FlashcardPreview() {
    XuemiTheme {
    }
}