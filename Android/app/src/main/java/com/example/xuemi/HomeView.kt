package com.example.xuemi

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.absolutePadding
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp


@Preview(showBackground = true, showSystemUi = true)
@Composable
fun Home() {
    Column {// Whole app Column
        Text(
            "Home",
            fontSize = 50.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(vertical = 20.dp, horizontal = 16.dp)
        )

        Button(onClick = {  },
            colors = ButtonDefaults.buttonColors(Color(3,115,206)),
            //border = BorderStroke(6.dp, Brush.verticalGradient(listOf(Color.Black, Color.White))),
            shape = RoundedCornerShape(20.dp),
            modifier = Modifier.padding(horizontal = 16.dp))
        {
            Image(
                painter = painterResource(id = R.drawable.continue_learning),
                contentDescription = "Continue learning button",
                modifier = Modifier
                    .size(900.dp,136.dp)
            )
        }
        Row {// 1st button row
            Button(onClick = { /*TODO*/ }, colors = ButtonDefaults.buttonColors(Color(126, 190, 240)), /*border = BorderStroke(6.dp,
                Brush.verticalGradient(listOf(Color(90, 142, 179), Color.White))),*/ modifier = Modifier.absolutePadding(top = 14.dp, bottom = 14.dp, right = 12.dp, left = 28.dp), shape = RoundedCornerShape(20.dp)
            ) {
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
                        fontWeight = FontWeight.Bold
                    )
                }

            }
            Button(onClick = { /*TODO*/ }, colors = ButtonDefaults.buttonColors(Color(126, 190, 240)), /*border = BorderStroke(6.dp,
                Brush.verticalGradient(listOf(Color(90, 142, 179), Color.White))),*/ modifier = Modifier.padding(horizontal = 1.dp, vertical = 14.dp), shape = RoundedCornerShape(20.dp)
            ) {
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
                        fontWeight = FontWeight.Bold
                    )
                }

            }

        }
        Row {// 2nd button row
            Button(onClick = { /*TODO*/ }, colors = ButtonDefaults.buttonColors(Color(126, 190, 240)), /*border = BorderStroke(6.dp,
                Brush.verticalGradient(listOf(Color(90, 142, 179), Color.White))),*/ modifier = Modifier.absolutePadding(right = 12.dp, left = 28.dp), shape = RoundedCornerShape(20.dp)
            ) {
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
                        fontWeight = FontWeight.Bold
                    )
                }

            }
            Button(onClick = { /*TODO*/ }, colors = ButtonDefaults.buttonColors(Color(126, 190, 240)), /*border = BorderStroke(6.dp,
                Brush.verticalGradient(listOf(Color(90, 142, 179), Color.White))),*/ modifier = Modifier.padding(horizontal = 1.dp), shape = RoundedCornerShape(20.dp)
            ) {
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
                        fontWeight = FontWeight.Bold
                    )
                }

            }

        }
        Button(onClick = { /*TODO*/ },
            colors = ButtonDefaults.buttonColors(Color(126, 190, 240)),
            /*border = BorderStroke(6.dp, Brush.verticalGradient(listOf(Color(90, 142, 179), Color.White))),*/
            shape = RoundedCornerShape(20.dp),
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 25.dp, vertical = 15.dp))


        {
            Text(
                text = "O-Level\n\nPractice",
                fontSize = 40.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(vertical = 7.dp)
            )
        }


    }

}