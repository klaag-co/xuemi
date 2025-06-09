
import android.annotation.SuppressLint
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import androidx.room.Entity
import androidx.room.PrimaryKey
import org.sstinc.xuemi.MyViewModel
import org.sstinc.xuemi.quiz.Word


@Entity
data class Afolder (
    @PrimaryKey(autoGenerate = true)
    val id: Int = 0,
    val name: String,
    val items: List<Word>
)

@SuppressLint("UnusedMaterial3ScaffoldPaddingParameter")
@Composable
fun Vocabulary(viewModel: MyViewModel, navController: NavController) {
    val sectionedData = remember { mutableStateOf<List<Word>>(emptyList()) }

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
        Column(Modifier.padding(start = 20.dp, end = 20.dp, top = 10.dp, bottom = 90.dp)) {
            Text(viewModel.selectJson(0).toString())
        }
    }

}