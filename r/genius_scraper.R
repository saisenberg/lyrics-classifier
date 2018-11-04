# Scrape rapgenius lyrics
library(dplyr)
library(geniusr)
library(jsonlite)
library(lubridate)
library(stringr)
genres <- fromJSON('.\\data\\json_genres.json')
source('.\\r\\get_song_meta_2.R')
source('.\\r\\scrape_lyrics_id_2.R')

# Enter your Genius API token
genius_token(force = TRUE)

# Artist name matching
genres$rap <- unlist(lapply(genres$rap, function(x){str_replace(string = x, pattern = 'asap', replacement = 'a$ap')}))

# Given artist name, collect list of randomly selected songs
collectSongs <- function(artist){
  print(paste0('artist: ', artist))
  artist_search <- search_artist(search_term = artist, n_results = 10)
  exact_search <- artist_search %>% filter(tolower(artist_name) == artist) %>% arrange(artist_id) %>% top_n(1, 'artist_id')
  if(nrow(exact_search)==1){
    artist_search <- exact_search
  }
  if(nrow(artist_search)==0){
    return(NULL)
  }
  artist_choice <- artist_search %>% sample_n(1)
  print(paste0('selected artist: ', tolower(artist_choice$artist_name)))
  artist_id <- artist_choice %>% select(artist_id)
  artist_name <- artist_choice %>% select(artist_name)
  songs <- get_artist_songs(artist_id = as.numeric(artist_id), include_features = FALSE) %>% filter(artist_id != 205617)
  songs <- songs[!grepl(pattern = 'Tracklist', x = songs$song_name),]
  songs <- songs[!grepl(pattern = 'TRACKLIST', x = songs$song_name),]
  songs <- songs[!grepl(pattern = 'tracklist', x = songs$song_name),]
  songs <- songs[!grepl(pattern = 'Album Art', x = songs$song_name),]
  songs <- songs[!grepl(pattern = 'ALBUM ART', x = songs$song_name),]
  songs <- songs[!grepl(pattern = 'album art', x = songs$song_name),]
  songs <- songs[!grepl(pattern = 'Script', x = songs$song_name),]
  songs <- songs[!grepl(pattern = 'SCRIPT', x = songs$song_name),]
  songs <- songs[!grepl(pattern = 'script', x = songs$song_name),]
  songs <- songs[!grepl(pattern = 'Transcript', x = songs$song_name),]
  songs <- songs[!grepl(pattern = 'TRANSCRIPT', x = songs$song_name),]
  songs <- songs[!grepl(pattern = 'transcript', x = songs$song_name),]
  songs <- songs[!grepl(pattern = 'Interview', x = songs$song_name),]
  songs <- songs[!grepl(pattern = 'INTERVIEW', x = songs$song_name),]
  songs <- songs[!grepl(pattern = 'interview', x = songs$song_name),]
  songs <- songs[!grepl(pattern = 'Speech', x = songs$song_name),]
  songs <- songs[!grepl(pattern = 'SPEECH', x = songs$song_name),]
  songs <- songs[!grepl(pattern = 'speech', x = songs$song_name),]
  songs <- mutate(songs, choice_weights = apply(songs, 1, function(x){max(sqrt(as.numeric(x[4])),1)}))
  songs <- songs %>% sample_n(min(ceiling(nrow(songs)*0.50), 75), weight = choice_weights) %>% arrange(-annotation_count)
  return(songs)
}

# Given list of songs, collect lyrics
collectLyrics <- function(songs){
  n1 <- now()
  print('[collecting songs...]')
  songs <- t(mapply(scrape_lyrics_id_2, songs$song_id))
  songs[,c(1)] <- lapply(songs[,c(1)], function(x){paste(x, collapse='')})
  songs <- as.data.frame(songs)
  songs[,c(1:5)] <- apply(songs[,c(1:5)], 2, function(x){unlist(lapply(x, '[[', 1))})
  n2 <- now()
  print(paste0('songs collected! time taken: ', as.numeric(round(difftime(n2, n1, units = 'mins'),1))))
  return(songs)
}

# Create dataframe of rap lyrics
collectGenre <- function(genre, size, min_characters, max_characters){
  t1 <- now()
  artists <- c()
  genre_index <- which(names(genres)==genre)
  df <- data.frame()
  while(nrow(df)<size){
    artist <- 'INITIAL'
    while(artist %in% c('INITIAL', artists)){
      artist <- sample(unname(genres[genre_index])[[1]], 1) 
    }
    artists <- c(artists, artist)
    data <- collectLyrics(collectSongs(artist = artist))
    data <- data %>% filter(!(song_id %in% df$song_id))
    df <- bind_rows(df, data)
    df <- df %>% mutate(characters = nchar(line)) %>% filter(characters >= min_characters, characters <= max_characters)
    closeAllConnections()
    print(paste0('number of rows: ', nrow(df)))
    Sys.sleep(time = 3)
  }
  rm(genre_index, artist, data)
  t2 <- now()
  print(paste0('total time taken: ', as.numeric(round(difftime(t2, t1, units = 'mins'),1))))
  df$genre <- genre
  return(df)
}

# Scrape lyrics for each genre
country <- collectGenre('country', 1500, 750, 2500)
metal <- collectGenre('metal', 1500, 750, 2500)
pop <- collectGenre('pop', 1500, 750, 3500)
rap <- collectGenre('rap', 1500, 1750, 4500)
rock <- collectGenre('rock', 1500, 750, 2000)
soul <- collectGenre('soul', 1500, 750, 2000)

# Combine all rows
lyrics <- bind_rows(country, metal, pop, rap, rock, soul)
write.csv(lyrics, '.\\data\\lyrics.csv', row.names = FALSE)