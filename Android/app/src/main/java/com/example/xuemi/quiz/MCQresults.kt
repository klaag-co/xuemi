package com.example.xuemi.quiz

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.size
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

@Composable
fun Chart(
    color: Color,
    outerRadius: Dp = 100.dp,
    innerRadius: Dp = outerRadius/3
) {
    Canvas(modifier = Modifier.size(outerRadius)) {
        val canvasWidth = size.width
        val canvasHeight = size.height

        drawCircle(
            color = color,
            radius = minOf(canvasWidth, canvasHeight) / 2
        )

        drawCircle(
            color = Color.White,
            radius = innerRadius.toPx(),
        )
    }
}


@Preview(showBackground = true, showSystemUi = true)
@Composable
fun MCQresults() {
    val halfWrong: Boolean = true

    Column {
        if (halfWrong) {
            Text(
                "继续努力！💪",
                style = MaterialTheme.typography.displayLarge
            )
        } else {
            Text(
                "好棒喔！👏",
                style = MaterialTheme.typography.displayLarge
            )
        }
        Chart(Color.Black)
    }

}