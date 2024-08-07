package com.example.xuemi

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
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
    Acknowledgement("CL Department", "Client", R.drawable.building_2_fill)
)
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsView() {
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
                    onClick = { /* wattesigma */ }
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
    }
}

@Preview(showBackground = true)
@Composable
fun SettingsViewPreview() {
    SettingsView()
}
