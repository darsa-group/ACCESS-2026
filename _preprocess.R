library("googlesheets4")
library("glue")
library("dplyr")
library("stringr")
library("rjson")


ROLES <- c("keynote", "assistant", "organiser")
SOCIAL_LINKS_MAP <- list(
orcid=list(
  icon="orcid",
  icon_pack= "fab",
  name= "ORCID",
  url= "https://orcid.org/{value}"
),
github=list(
  icon="github",
  icon_pack= "fab",
  name= "Github",
  url= "https://github.com/{value}"
),
research_gate=list(
  icon="researchgate",
  icon_pack= "fab",
  name= "RG",
  url= "https://www.researchgate.net/profile/{value}"
)
)


make_links <- function(row){

  links <- lapply(names(SOCIAL_LINKS_MAP), function(n){
    value <- row[[n]]
    if(is.na(value))
      return(NULL)
    l <- SOCIAL_LINKS_MAP[[n]]
    l$url <- glue(l$url)
    l <-rjson::toJSON(l )
    l
  })
  links <- links[lengths(links) != 0]
  links <- sprintf("[%s]", paste(links, collapse=", "))
  links
}



DEFAULT_PICTURE_FILE<- "content/people/_default_pict.png"
PEOPLE_TEMPLATE_FILE <- "content/people/_people.md.template"

AUTO_PPL_DIR_PREFIX <- "auto-"
creds = Sys.getenv('GOOGLE_SERVICE_JSON_KEY')
stopifnot( creds != "") #, 'Could not find environment variable `GOOGLE_SERVICE_JSON_KEY`')

people_sheet = Sys.getenv('PEOPLE_GOOGLE_SHEET_ID')
stopifnot( people_sheet != "") #, 'Could not find environment variable `PEOPLE_GOOGLE_SHEET_ID`')

people_template = paste(readLines(PEOPLE_TEMPLATE_FILE), collapse="\n")
stopifnot(!is.null(people_template))

if(file.exists(creds)){
  file.copy(from = creds, to=tmpf <- tempfile(fileext = ".json"))
}
if(!file.exists(creds))
  cat(creds, file = tmpf <- tempfile(fileext = ".json"))

gs4_auth(
  path=tmpf,
  scopes = "https://www.googleapis.com/auth/spreadsheets.readonly",cache=FALSE)

df <- read_sheet(people_sheet, na=c("", "NA"))
df <- filter(df, !is.na(id))

print(df)

make_people <- function(id_){

  d <- paste(tempdir(), id_, sep="/")

  dir.create(d)
  row <- filter(df, id==id_)
  print(row)
  themes <- select(row, starts_with("theme_"))
  themes <- unlist(as.vector(themes))
  themes <- names(themes[themes])
  themes <- str_replace(themes,"theme_","")

  tags <- sapply(ROLES,function(i) {
    print(paste0("role_",i))
    ifelse(row[[paste0("role_",i)]], i, NA)}
    )

  row$weight = row$role_organiser * 7 + row$role_keynote * 5 + row$role_assistant * 1
  tags <- na.omit(tags)
  #tags <- c(row$role)
  #todo add an alumni tag if end date is in the past
  row$tags <- glue('[{paste(tags, collapse=", ")}]')

  row$social_links <- make_links(row)

  content <-glue_data(row,people_template)
  
  out <- paste(d, "index.md", sep="/")
  con <- file(out, open = "w", encoding = "UTF-8")
  writeLines(content, con)
  close(con)

  dst_pict_file <- paste(d,'featured.jpg',sep='/')


  if(!is.na(row$picture_url)){
    picture_file <- paste("assets", "image", row$picture_url, sep="/")

    if(file.exists(picture_file)){
      file.copy(picture_file, dst_pict_file)
    }
    else{
      download.file(
        url  = row$picture_url,
        destfile = dst_pict_file,
        mode = "wb",
        quiet = TRUE
      )
    }
  }
  else{
    warning(glue('No picture for member `{id_}`'))
    file.copy(DEFAULT_PICTURE_FILE, dst_pict_file)
  }

  final_dir <- paste("content", "people",paste0(AUTO_PPL_DIR_PREFIX, id_), sep="/")
  # print("=== DEBUGGINNG ON ===")
  # print(paste0("temporary dir = ", d))
  # print(paste0("final_dir = ", final_dir))
  
  if (dir.exists(final_dir)) {
    unlink(final_dir, recursive = TRUE, force = TRUE)
    }

  dir.create(final_dir, recursive = TRUE, showWarnings = FALSE)

  file.copy(
    from = list.files(d, full.names = TRUE),
    to = final_dir,
    recursive = TRUE
  )

  unlink(d, recursive = TRUE, force = TRUE)

}

o <- lapply(df$id, make_people)


