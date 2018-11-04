get_song_meta_2 <- function (song_id, access_token = genius_token()) 
{
  base_url <- "api.genius.com/songs/"
  req <- httr::GET(url = paste0(base_url, song_id), httr::add_headers(Authorization = paste0("Bearer ", 
                                                                                             access_token)))
  httr::stop_for_status(req)
  res <- httr::content(req)
  res <- res$response
  song_info <- purrr::map_df(1:length(res), function(x) {
    trk <- res[[x]]
    alb <- res[[x]]$album
    art <- res[[x]]$primary_artist
    stat <- res[[x]]$stats
    list(song_id = trk$id, 
         song_name = trk$title_with_featured,
         song_lyrics_url = trk$url,
         artist_id = art$id,
         artist_name = art$name, 
         artist_url = art$url 
    )
  })
  return(tibble::as_tibble(unique(song_info)))
}
