# Obtaining canopy height data

obtain_height <- function(id) {
  require(traits)
  options(betydb_url = "https://terraref.org/bety/",
          betydb_api_version = 'v1')
  
  # metadata
  meta <- betydb_experiment(id = id)
  
  # Extract site names
  sitenames <- unique(meta$sites$site.sitename)
  string1 <- paste(Reduce(intersect2, strsplit(sitenames, NULL)), collapse = '')
  string <- substr(string1, 1, nchar(string1) - 16)
  season <- gsub(" ", "_", gsub("MAC Field Scanner ", "", string))
  num <- gsub("Season_", "", season)
  
    # Scrape Dryad data-set of traits_data.zip
  dir.create("DRYAD_data")
  fzip <- paste0(getwd(), "/DRYAD_data/traits_data.zip")
  download.file("https://datadryad.org/stash/downloads/file_stream/396628", fzip)
  exdir <- paste0(getwd(), "/DRYAD_data/")
  unzip(fzip, exdir = exdir)
  
  # Read in "canopy_height" files, manual or sensor
  fnames <- list.files(paste0(exdir, "traits/season_", num, "_traits/"))
  ind <- grep("canopy_height", fnames)
  heights <- c()
  for(i in ind){
    temp <- read.csv(paste0(exdir, "traits/season_", num, "_traits/", fnames[i]))
    heights <- rbind.data.frame(heights, temp)
  }
 
  # Save out, append date of retrieval?
  write.csv(heights, file = paste0(season, "_heights.csv"), row.names = FALSE)
  
  # Remove downloaded files
  system("rm -r DRYAD_data/")
}

intersect2 <- function (x, y)
{
  y <- as.vector(y)
  y[match(as.vector(x), y, 0L)]
}


