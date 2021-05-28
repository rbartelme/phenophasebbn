# Obtaining tall traits data

id = 6000000034 # season 6
id = 6000000010 # season 4
obtain_traits <- function(id) {
  require(traits)
  options(betydb_url = "https://terraref.org/bety/",
          betydb_api_version = 'v1')
  
  # metadata
  meta <- betydb_experiment(id = id)
  
  # Extract site names
  sitenames <- unique(meta$sites$site.sitename)
  string1 <- paste(Reduce(intersect2, strsplit(sitenames, NULL)), collapse = '')
  string <- substr(string1, 1, nchar(string1) - 16)
  
  
  # Obtain canopy heights trait data by season - can take a while
  heights <- betydb_query(sitename = paste0("~", string),
                       trait     =  "canopy_height",
                       limit     =  "none")
  
  # filter by method_name

  # Save out - remove later
  write.csv(traits, file = paste0("season_", season_number, "_traits.csv"), row.names = FALSE)
}

intersect2 <- function (x, y)
{
  y <- as.vector(y)
  y[match(as.vector(x), y, 0L)]
}


