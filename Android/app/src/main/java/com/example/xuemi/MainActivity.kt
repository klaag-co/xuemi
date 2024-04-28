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
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
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

        Button(onClick = { /*TODO*/ }, colors = ButtonDefaults.buttonColors(Color(3,115,206)), shape = RoundedCornerShape(20.dp), modifier = Modifier.padding(horizontal = 16.dp)) {
            Image(
                painter = painterResource(id = R.drawable.continue_learning),
                contentDescription = "Continue learning button",
                modifier = Modifier
                    .size(1000.dp,136.dp)
            )
        }
        Row {// 1st button row
            Button(onClick = { /*TODO*/ }, colors = ButtonDefaults.buttonColors(Color(126, 190, 240)), modifier = Modifier.padding(horizontal = 22.dp, vertical = 16.dp), shape = RoundedCornerShape(20.dp)) {
                Column {
                    Text(
                        text = "Secondary",
                        fontSize = 24.sp
                    )
                    Text(
                        text = "1",
                        fontSize = 70.sp,
                        modifier = Modifier.padding(horizontal = 35.dp),
                        fontWeight = FontWeight.Black
                    )
                    Text("")
                }

            }
            Button(onClick = { /*TODO*/ }, colors = ButtonDefaults.buttonColors(Color(126, 190, 240)), modifier = Modifier.padding(horizontal = 1.dp, vertical = 16.dp), shape = RoundedCornerShape(20.dp)) {
                Column {
                    Text(
                        text = "Secondary",
                        fontSize = 24.sp
                    )
                    Text(
                        text = "2",
                        fontSize = 70.sp,
                        modifier = Modifier.padding(horizontal = 35.dp,),
                        fontWeight = FontWeight.Black
                    )
                    Text("")
                }

            }


        }
    }
    
}

@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    XuemiTheme {
        Main()
    }
}
