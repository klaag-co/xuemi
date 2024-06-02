package com.example.xuemi

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
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.xuemi.ui.theme.XuemiTheme

@Composable
fun Secondary(viewModel: MyViewModel) {
    val numOfChapters = listOf<Int>(6, )

    Card(modifier = Modifier.fillMaxWidth().padding(horizontal = 25.dp, vertical = 15.dp),
        colors = CardDefaults.cardColors(
        containerColor = Color(126, 190, 240),
            contentColor = Color.White
    )){
        Row {
            Text(
                text = "Secondary ${viewModel.getSecondary()}",
                textAlign = TextAlign.Center,
                fontSize = 30.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.absolutePadding(top = 10.dp, bottom = 10.dp, right = 5.dp, left = 80.dp)
            )

        }
    }
}




@Preview(showSystemUi = true)
@Composable
fun FlashcardPreview() {
    XuemiTheme {
        Secondary(viewModel = MyViewModel())
    }
}