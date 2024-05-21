package com.example.xuemi
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp

@Composable
fun Notes() {
    Button(onClick = { /*TODO*/ },
        colors = ButtonDefaults.buttonColors(Color(3,115,206)),
        border = BorderStroke(6.dp, Brush.verticalGradient(listOf(Color.Black, Color.White))),
        shape = RoundedCornerShape(20.dp),
        modifier = Modifier.padding(horizontal = 16.dp))
    {
        Image(
            painter = painterResource(id = R.drawable.continue_learning3),
            contentDescription = "Continue learning button",
            modifier = Modifier
                .size(1000.dp,136.dp)
        )
    }
}