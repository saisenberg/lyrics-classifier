## Lyrics, Pt. 1: Genre Classification

In today’s day and age, we’re seeing more crossover than ever between musical artists of different genres.  This project builds a model which predicts a song's genre based solely on its lyrical content.

A full description of the project can be found at [**saisenberg.com**](https://saisenberg.com/projects/lyrics-classifier.html).

### Getting started

#### Prerequisite software

* Python (suggested install through [Anaconda](https://www.anaconda.com/download/))


* [R](https://www.r-project.org/)

#### Prerequisite libraries

* Python:
    - bs4, numpy, pandas, re, requests, sklearn, string, warnings (```all installed with Anaconda```)
    - json (```!pip install json```)
    - nltk (```!pip install nltk```)
    - xgboost (```!pip install xgboost```)
    

* R:

```
lib <- c('dplyr', 'geniusR', 'jsonlite', 'lubridate', 'stringr')
install_packages(lib)
```
    
    
### Instructions for use

#### 1. Run the code contained in */python/artist_collection.ipynb*

This code scrapes *[Billboard](https://www.billboard.com)*, *[Ranker](https://ranker.com)*, and *[TheTopTens](https://www.thetoptens.com)* for artists of different genres. Any duplicate artists are removed as appropriate. 

The output of */python/artist_collection.ipynb* can also be found at */data/json_genres.json*.

#### 2. Run */r/genius_scraper.R*

This program scrapes and cleans lyrics from *[Genius](http://genius.com)*, categorizing results by genre. Visit *[Genius](https://genius.com/api-clients)* to view or obtain a Genius client access token.

The output of */r/genius_scraper.R* can also be found at */data/lyrics.csv*.

#### 3. Run the code contained in */python/lyrics_classifier.ipynb*

This code preprocesses all lyrics for modeling, and runs Naïve Bayes, support vector machine, and gradient boosting models to predict a song's genre from its lyrics.


### Author

* **Sam Isenberg** - [saisenberg.com](https://saisenberg.com) | [github.com/saisenberg](https://github.com/saisenberg)


### License

This project is licensed under the MIT License - see the *LICENSE.md* file for details.

### Acknowledgements

* [Billboard](https://www.billboard.com)
* [Ewen Henderson](https://cran.r-project.org/web/packages/geniusr/geniusr.pdf)
* [Genius](http://genius.com)
* [Ranker](https://ranker.com)
* [TheTopTens](https://www.thetoptens.com)
