package com.example.xuemi
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.absolutePadding
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Menu
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material.icons.outlined.Star
import androidx.compose.material3.BottomAppBar
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
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
            MainBottomBar()
        }
    }
}

@Composable
fun Main() {


    Column {// Whole app Column
        Text(
            "Home",
            fontSize = 65.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(horizontal = 16.dp)
        )

        Button(onClick = { /*TODO*/ },
            colors = ButtonDefaults.buttonColors(Color(3,115,206)),
            border = BorderStroke(6.dp, Brush.verticalGradient(listOf(Color.Black, Color.White))),
            shape = RoundedCornerShape(20.dp),
            modifier = Modifier.padding(horizontal = 16.dp))
        {
            Image(
                painter = painterResource(id = R.drawable.continue_learning),
                contentDescription = "Continue learning button",
                modifier = Modifier
                    .size(1000.dp,136.dp)
            )
        }
        Row {// 1st button row
            Button(onClick = { /*TODO*/ }, colors = ButtonDefaults.buttonColors(Color(126, 190, 240)), border = BorderStroke(6.dp,Brush.verticalGradient(listOf(Color(90, 142, 179), Color.White))), modifier = Modifier.absolutePadding(top = 14.dp, bottom = 14.dp, right = 12.dp, left = 28.dp), shape = RoundedCornerShape(20.dp)) {
                Column {
                    Text(
                        text = "Secondary",
                        fontSize = 24.sp,

                    )
                    Text(
                        text = "1",
                        fontSize = 65.sp,
                        modifier = Modifier
                            .padding(horizontal = 35.dp)
                            .absolutePadding(bottom = 10.dp),
                        fontWeight = FontWeight.Black
                    )
                }

            }
            Button(onClick = { /*TODO*/ }, colors = ButtonDefaults.buttonColors(Color(126, 190, 240)), border = BorderStroke(6.dp,Brush.verticalGradient(listOf(Color(90, 142, 179), Color.White))), modifier = Modifier.padding(horizontal = 1.dp, vertical = 14.dp), shape = RoundedCornerShape(20.dp)) {
                Column {
                    Text(
                        text = "Secondary",
                        fontSize = 24.sp
                    )
                    Text(
                        text = "2",
                        fontSize = 65.sp,
                        modifier = Modifier
                            .padding(horizontal = 35.dp)
                            .absolutePadding(bottom = 10.dp)
                        ,
                        fontWeight = FontWeight.Black
                    )
                }

            }

        }
        Row {// 2nd button row
            Button(onClick = { /*TODO*/ }, colors = ButtonDefaults.buttonColors(Color(126, 190, 240)), border = BorderStroke(6.dp,Brush.verticalGradient(listOf(Color(90, 142, 179), Color.White))), modifier = Modifier.absolutePadding(right = 12.dp, left = 28.dp), shape = RoundedCornerShape(20.dp)) {
                Column {
                    Text(
                        text = "Secondary",
                        fontSize = 24.sp
                    )
                    Text(
                        text = "3",
                        fontSize = 65.sp,
                        modifier = Modifier
                            .padding(horizontal = 35.dp)
                            .absolutePadding(bottom = 10.dp)
                        ,
                        fontWeight = FontWeight.Black
                    )
                }

            }
            Button(onClick = { /*TODO*/ }, colors = ButtonDefaults.buttonColors(Color(126, 190, 240)), border = BorderStroke(6.dp,Brush.verticalGradient(listOf(Color(90, 142, 179), Color.White))), modifier = Modifier.padding(horizontal = 1.dp), shape = RoundedCornerShape(20.dp)) {
                Column {
                    Text(
                        text = "Secondary",
                        fontSize = 24.sp
                    )
                    Text(
                        text = "4",
                        fontSize = 65.sp,
                        modifier = Modifier
                            .padding(horizontal = 35.dp)
                            .absolutePadding(bottom = 10.dp)
                        ,
                        fontWeight = FontWeight.Black
                    )
                }

            }

        }
        Button(onClick = { /*TODO*/ },
            colors = ButtonDefaults.buttonColors(Color(126, 190, 240)),
            border = BorderStroke(6.dp, Brush.verticalGradient(listOf(Color(90, 142, 179), Color.White))),
            shape = RoundedCornerShape(20.dp),
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 25.dp, vertical = 8.dp))


        {
            Text(
                text = "O-Level\n\nPractice",
                fontSize = 40.sp,
                fontWeight = FontWeight.Black,
                modifier = Modifier.padding(vertical = 5.dp)
            )
        }


    }
    
}
@Composable
fun MainBottomBar() {
    var currentpage by remember { mutableStateOf("Home") }


    if (currentpage == "Home") {
        Main()
    } else if (currentpage == "Favourites") {
        Favourites()
    } else if (currentpage == "Notes") {
        Notes()
    } else if (currentpage == "Settings") {
        /*TODO*/
    }

    BottomAppBar (
        actions = {
            IconButton(onClick = { currentpage = "Home"}) {
                Icon(imageVector = Icons.Outlined.Home, contentDescription = null)
            }
            IconButton(onClick = { currentpage = "Favourites" }) {
                Icon(imageVector = Icons.Outlined.Star, contentDescription = null)
            }
            IconButton(onClick = { currentpage = "Notes" }) {
                Icon(imageVector = Icons.Outlined.Menu, contentDescription = null)
            }
            IconButton(onClick = { currentpage = "Settings" }) {
                Icon(imageVector = Icons.Outlined.Settings, contentDescription = null)
            }
        }
    )
}
@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    XuemiTheme {
        Main()
    }
}
