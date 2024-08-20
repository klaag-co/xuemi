package org.sstinc.xuemi

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController

data class Acknowledgement(
    val name: String,
    val role: String,
    val icon: Int
)

val acknowledgements = listOf(
    Acknowledgement("Kmy Er Sze Lei", "Project Coordinator, Designer, Developer", R.drawable.person_fill),
    Acknowledgement("Gracelyn Gosal", "Lead Developer (iOS), Marketing", R.drawable.hammer_fill),
    Acknowledgement("Lau Rei Yan Abigail", "Lead Developer (Android)", R.drawable.hammer_fill),
    Acknowledgement("Yoshioka Lili", "Lead Designer, Marketing", R.drawable.paintbrush_fill),
    Acknowledgement("Yeo Shu Axelia", "Marketing IC", R.drawable.megaphone_fill),
    Acknowledgement("Chay Yu Hung Tristan", "Consultant", R.drawable.person_fill),
    Acknowledgement("Ms Wong Lu Ting", "Head of Department", R.drawable.person_fill),
    Acknowledgement("Ms Yap Hui Min", "Teacher-in-charge", R.drawable.person_fill),
    Acknowledgement("Ms Tan Sook Qin", "Teacher-in-charge", R.drawable.person_fill),
    Acknowledgement("Ms Yeo Sok Hui", "Teacher-in-charge", R.drawable.person_fill),
    Acknowledgement("Ms Xu Wei", "Teacher-in-charge", R.drawable.person_fill),
    Acknowledgement("CL Department", "Client", R.drawable.building_2_fill)
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsView(navController: NavHostController) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Settings",
                        fontSize = 45.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            )
        },
        modifier = Modifier.padding(bottom = 20.dp)
    ) { paddingValues ->
        LazyColumn(
            contentPadding = paddingValues,
            modifier = Modifier.padding(16.dp)
        ) {
            item {
                SectionHeader("App")
            }
            item {
                NavigationCard(
                    title = "About Our App",
                    onClick = { navController.navigate("helloWorld") }
                )
            }
            item {
                SectionHeader("Acknowledgement")
            }
            items(acknowledgements) { person ->
                AcknowledgementDetailView(person)
            }
            item {
                SectionHeader("Help and Support")
            }
            item {
                HelpSupportView()
            }
        }
    }
}

@Composable
fun SectionHeader(title: String) {
    Text(
        text = title,
        fontSize = 22.sp,
        fontWeight = FontWeight.Bold,
        modifier = Modifier.padding(vertical = 8.dp)
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NavigationCard(title: String, onClick: () -> Unit) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        onClick = onClick
    ) {
        Row(
            modifier = Modifier
                .padding(16.dp)
                .fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(title)
            Text("→", color = Color.Gray)
        }
    }
}

@Composable
fun AcknowledgementDetailView(person: Acknowledgement) {
    Row(
        modifier = Modifier
            .padding(vertical = 8.dp)
            .fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.weight(1f)
        ) {
            Text(
                text = person.name,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = person.role,
                color = Color.Gray
            )
        }
        Icon(
            painter = painterResource(id = person.icon),
            contentDescription = null,
            modifier = Modifier.size(24.dp),
            tint = Color.Blue
        )
    }
}

@Composable
fun HelpSupportView() {
    Column(
        modifier = Modifier
            .padding(vertical = 16.dp)
    ) {
        Text("For help and support, please contact:")
        Text(
            text = "klaag.co@gmail.com",
            color = Color.Blue,
            modifier = Modifier.clickable {
            }
        )
        Spacer(modifier = Modifier.height(40.dp))
    }
}

@Composable
fun HelloWorldScreen() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
    ) {
        Text(
            text = "Our app, Xuemi, is an app that will help secondary school students improve their Chinese language in a more convenient manner. Students will be able to study anywhere, anytime. The app features will allow students to practise their reading and writing and strengthen their use of the Chinese language. Students will be able to learn how to write the Chinese words correctly, and read passages fluently and with confidence. The app includes a test function which tests students based on the ‘O’ level marking scheme. The content from sec 1-sec 4 will be compiled in this app, allowing easier access to materials for students. Additionally, we will include a note-taking function in the app.",
            fontSize = 20.sp
        )
    }
}

@Composable
fun MainScreen() {
    val navController = rememberNavController()
    NavHost(navController = navController, startDestination = "settings") {
        composable("settings") { SettingsView(navController) }
        composable("helloWorld") { HelloWorldScreen() }
    }
}

@Preview(showBackground = true)
@Composable
fun SettingsViewPreview() {
    MainScreen()
}
