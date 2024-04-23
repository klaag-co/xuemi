package com.example.xuemi
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.xuemi.ui.theme.XuemiTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            Main()
        }
    }
}

@Composable
fun Main() {
    Column {// Whole app Column
        Text(
            "Home",
            fontSize = 70.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(horizontal = 16.dp)
        )
        Button(onClick = { /*TODO*/ }, shape = RoundedCornerShape(20.dp)) {
            Image(
                painter = painterResource(id = R.drawable.continue_learning),
                contentDescription = "Continue learning button",
                modifier = Modifier.background(Color.Black)

            )
        }
//        Row {// 1st button row
//            Button(onClick = { /*TODO*/ }, modifier = Modifier.padding(16.dp), shape = RoundedCornerShape(20.dp)) {
//                Column {
//                    Text(
//                        text = "Secondary",
//                        fontSize = 30.sp
//                    )
//                    Text(
//                        text = "1",
//                        fontSize = 80.sp,
//                        modifier = Modifier.padding(horizontal = 58.dp,)
//                    )
//                }
//
//            }
//
//
//        }
    }
    
}

@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    XuemiTheme {
        Main()
    }
}
