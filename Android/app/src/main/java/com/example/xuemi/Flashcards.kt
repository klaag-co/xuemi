package com.example.xuemi

import android.adservices.topics.Topic
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.absolutePadding
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import androidx.navigation.compose.rememberNavController
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
                        .padding(5.dp)

                )
            }
        }

    }

}

@Composable
fun Chapter(viewModel: MyViewModel, navController: NavController) {
    Column {
        title(viewModel)
        topictemplate(viewModel, navController, "1")
        topictemplate(viewModel, navController,"2")
        topictemplate(viewModel, navController,"3")
    }
}

@Composable
fun Topic(viewModel: MyViewModel) {
    Column {
        title(viewModel)
        quiztemplate(viewModel, "Handwriting")
        quiztemplate(viewModel, "MCQ")
        quiztemplate(viewModel, "Flashcards")
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
                    .padding(5.dp)

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
                    .padding(5.dp)

            )
        }
    }
}
@Composable
fun topictemplate(viewModel: MyViewModel, navController: NavController, topic: String?) {
    Button(
        onClick = { viewModel.updateItem(2, "$topic")
                  navController.navigate("topic") },
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
                    .padding(5.dp)

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