scrape_lyrics_id_2 <- function (song_id, access_token = genius_token()) 
{
  meta <- get_song_meta_2(song_id)
  session <- suppressWarnings(rvest::html(meta$song_lyrics_url))
  lyrics <- rvest::html_nodes(session, ".lyrics p")
  xml2::xml_find_all(lyrics, ".//br") %>% xml2::xml_add_sibling("p", 
                                                                "\\n")
  xml2::xml_find_all(lyrics, ".//br") %>% xml2::xml_remove()
  lyrics <- rvest::html_text(lyrics)
  lyrics <- lyrics[1]
  lyrics <- unlist(stringr::str_split(lyrics, pattern = "\\n"))
  lyrics <- lyrics[lyrics != ""]
  lyrics <- lyrics[!stringr::str_detect(lyrics, pattern = "\\\\[|\\\\]")]
  lyrics <- tibble::tibble(line = lyrics)
  
  if(nrow(lyrics)==0){
    lyrics <- as.data.frame(matrix(nrow = 1, ncol = 5))
    names(lyrics) <- c('line', 'song_id', 'song_name', 'artist_id', 'artist_name')
    lyrics$line[1] <- 'ERROR'
    lyrics$song_id[1] <- 'ERROR'
    lyrics$song_name[1] <- 'ERROR'
    lyrics$artist_id[1] <- 'ERROR'
    lyrics$artist_name[1] <- 'ERROR'
    return(tibble::as_tibble(lyrics))
  } else {
    lyrics$song_id <- meta$song_id
    lyrics$song_name <- meta$song_name
    lyrics$artist_id <- meta$artist_id
    lyrics$artist_name <- meta$artist_name
    return(tibble::as_tibble(lyrics))
  }
}
