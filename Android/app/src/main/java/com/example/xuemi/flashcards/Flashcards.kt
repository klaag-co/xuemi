package com.example.xuemi.flashcards

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.MaterialTheme
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.xuemi.R


@Composable
fun FlashcardScreen(wordSets: List<List<String>>) {
    val currentSet by rememberSaveable { mutableIntStateOf(0) }
    Flashcard(wordSets[currentSet])
}

@Composable
fun Flashcard(wordSets: List<String>) {
    Card (elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),modifier = Modifier.fillMaxSize(0.8f)){
        Column (modifier = Modifier.padding(10.dp).fillMaxHeight().fillMaxWidth(0.5f)){
            Row {
                Text("中${wordSets[0]}:单元${wordSets[1]}", style = MaterialTheme.typography.h6)
                IconButton(
                    onClick = { /*TODO*/ }
                ) {
                    Icon(
                        painter = painterResource(id = R.drawable.o_bookmark),
                        contentDescription = "bookmark?"
                    )
                }
            }
            Text(wordSets[2], style = MaterialTheme.typography.h4)
            Text(wordSets[3], style = MaterialTheme.typography.h5)
            Text(wordSets[4], style = MaterialTheme.typography.h5)
            Text(wordSets[5], style = MaterialTheme.typography.h6)
        }
    }
}

@Preview(showSystemUi = true)
@Composable
fun preview() {
    FlashcardScreen(wordSets = listOf( listOf("二", "一", "爱不释手", "aì bù shì shǒu", "喜爱的舍不得放手", "to love something too much to part with it (idiom)"), listOf("二", "一", "毅力", "yì lì", "（名）坚定持久，毫不动摇的意志。", "perseverance; willpower")))
}
