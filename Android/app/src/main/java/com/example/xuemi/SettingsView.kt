package com.example.xuemi

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.Card
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Preview(showSystemUi = true)
@Composable
fun Person() {
    Card {
        Row {
            Column {
                Text(
                    "Title",
                    fontWeight = FontWeight.Bold
                )
                Text(
                    "Description"
                )
            }
            Icon(painter = painterResource(id = R.drawable.home), contentDescription = "icon")
        }
    }
}

@Composable
fun Settings() {
    LazyColumn {

        item {
            Text(
                "Settings",
                fontSize = 100.sp,
                fontWeight = FontWeight.Bold,
            )
        }
    }
}

   