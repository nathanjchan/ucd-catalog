# Libraries ----
library(stringr)


# Functions ----
split_line = function(one_line) {
  # splits one line of string into a list of multiple strings
  code_rest = str_split(one_line, " ", 2) # separate code
  number_rest = str_split(code_rest[[1]][2], "-", 2) # separate number (make sure hyphen is the right type of hyphen)
  title_rest = str_split(number_rest[[1]][2], fixed("("), 2) # separate title
  units_rest = str_split(title_rest[[1]][2], fixed(")"), 2) # separate units
  time_rest = str_split(units_rest[[1]][2], fixed(". "), 2) # separate time
  desc_rest = str_split(time_rest[[1]][2], "GE credit:|Effective:", 2) # separate description
  line_list = c()
  line_list[1] = code_rest[[1]][1]
  line_list[2] = number_rest[[1]][1]
  line_list[3] = title_rest[[1]][1]
  line_list[4] = units_rest[[1]][1]
  line_list[5] = time_rest[[1]][1]
  line_list[6] = desc_rest[[1]][1]
  if (is.na(str_detect(desc_rest[[1]][2], "Effective:")) == FALSE & 
      str_detect(desc_rest[[1]][2], "Effective:") == TRUE) {
    ge_rest = str_split(desc_rest[[1]][2], "Effective:", 2)
    line_list[7] = ge_rest[[1]][2]
    line_list[8] = ge_rest[[1]][1]
  } else {
    line_list[7] = desc_rest[[1]][2]
    line_list[8] = NA
  }
  return(line_list)
}


read_one_file = function(file_name, directory_name) {
  # given the file path, reads a single file and returns a data frame
  path = paste(directory_name, file_name, sep = "/")
  lines = readLines(path)
  lines = unique(lines)
  lines = lines[-2]
  Encoding(lines) = "UTF-8"
  df = lapply(lines, split_line)
  df = as.data.frame(do.call(rbind, df))
  names(df) = c("code", "number", "title", "units", "time", "description", "effective", "GE")
  return(df)
}


read_all_files = function(directory_name) {
  # reads all the files in a given directory, returns a completed data frame
  all_file_names = list.files(directory_name)
  df = lapply(all_file_names, read_one_file, directory_name = directory_name)
  df = do.call(rbind, df)
  return(df)
}


# Demo ----
catalog = read_all_files("catalog")
write.csv(catalog, "catalog.csv")


# example subset: finding classes that fulfill both SS and ACGH general education requirements
example = catalog[which(str_detect(catalog$GE, "SS") == TRUE & str_detect(catalog$GE, "ACGH")), ]
