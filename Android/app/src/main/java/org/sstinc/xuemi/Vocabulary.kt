
import android.annotation.SuppressLint
import android.util.Log
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.MutableLiveData
import androidx.navigation.NavController
import androidx.room.Entity
import androidx.room.PrimaryKey
import org.sstinc.xuemi.MyViewModel
import org.sstinc.xuemi.quiz.Topic
import org.sstinc.xuemi.quiz.Word
import org.sstinc.xuemi.quiz.generateListOfMCQQuestions


@Entity
data class Afolder (
    @PrimaryKey(autoGenerate = true)
    val id: Int = 0,
    val name: String,
    val items: List<Word>
)

@SuppressLint("UnusedMaterial3ScaffoldPaddingParameter")
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun Vocabulary(viewModel: MyViewModel, navController: NavController) {
    val sectionedData = remember { mutableStateOf<List<Word>>(emptyList()) }
    val allFolders by viewModel.folders.collectAsState()
    val sheetstate = rememberModalBottomSheetState()
    var isSheetOpen: Boolean by rememberSaveable { mutableStateOf(false) }


    LaunchedEffect(Unit) {
        viewModel.loadAllSections()
    }
    Scaffold(
        topBar = {
            Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 10.dp, horizontal = 15.dp)) {
                Text(
                    "Folders",
                    fontSize = 38.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding( vertical = 5.dp)
                )

                Button(onClick = {  viewModel.deleteAll()}) {
                    Text("delete")
                }
                IconButton(onClick = { navController.navigate("addvocab") }) {
                    Icon(
                        Icons.Default.Add,
                        contentDescription = "Add folder",
                        modifier = Modifier.fillMaxSize(0.9f)
                    )
                }
            }

        }
    ) {
        Column(Modifier.padding(start = 20.dp, end = 20.dp, top = 70.dp, bottom = 90.dp)) {

            LazyColumn {
                items(allFolders) { folder ->
                    Button (
                        onClick = {
                            viewModel.addQuiz(
                                      topic = folder.name,
                                      questions = generateListOfMCQQuestions(folder.items, limit = false),
                                      allowDupes = true
                            )
                            isSheetOpen = true
                             },
                        shape = RoundedCornerShape(10.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(3.dp),
                        colors = ButtonDefaults.buttonColors(Color(243, 242, 245)),

                        ) {
                        Text(folder.name, color = Color.Black)
                    }
                }
            }
            if (isSheetOpen) {
                ModalBottomSheet(sheetState = sheetstate, onDismissRequest = { isSheetOpen = false }) {
                    Topic(viewModel, navController)
                }
            }
        }
    }

}


@Composable
fun quiztemplate(viewModel: MyViewModel, navController: NavController, quiz: String) {
    LaunchedEffect(Unit) {
        viewModel.loadData("中${viewModel.getFromList(0)}.json")
    }

    val dataFromJson by viewModel.loadedData.collectAsState()
    val chapterData = dataFromJson?.chapters?.getOrNull(viewModel.getFromList(2).toIntOrNull() ?: 0)?.topics

    val name: String? = when (viewModel.getFromList(3)) {
        "一" -> chapterData?.topic1?.name
        "二" -> chapterData?.topic2?.name
        "三" -> chapterData?.topic3?.name
        else -> null
    }

    val topicExists = name?.let { viewModel.checkIfTopicExists(it) } ?: MutableLiveData(false)
    val topicExistsState by topicExists.observeAsState(false)

    val navigateToMCQ = remember { mutableStateOf(false) }

    // Log to check the value of `name` and `topicExistsState`
    Log.d("QuizTemplate", "Name: $name, Topic Exists: $topicExistsState")

    LaunchedEffect(topicExistsState, navigateToMCQ.value) {
        if (navigateToMCQ.value) {
            Log.d("QuizTemplate", "navigateToMCQ is true, navigating to $quiz with name: $name")

            if (topicExistsState && name != null) {
                navController.navigate("${quiz.lowercase()}/$name")
                Log.d("QuizTemplate", "Navigated to ${quiz.lowercase()}/$name")
            } else {
                Log.e("QuizTemplate", "Topic does not exist or name is null, cannot navigate.")
            }
            navigateToMCQ.value = false
        }
    }

    Button(
        onClick = {
            viewModel.updateItem(4, "${quiz.first()}")
            viewModel.updateItem(5, "true")

            when (quiz) {
                "MCQ" -> {
                    navigateToMCQ.value = true

                }
                "Flashcards" -> {
                    val navigatePath = "flashcards/${viewModel.getFromList(0)}/${viewModel.getFromList(1)}/${viewModel.getFromList(2)}/${viewModel.getFromList(3)}/0.chapter"
                    navController.navigate(navigatePath)
                    viewModel.saveContinueLearning()
                }
                else -> {
                    navController.navigate(quiz.lowercase())
                }
            }
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
