library(shiny)
library(rvest)
library(stringr)

shinyServer(function(input, output) {
  
  output$URL <- renderPrint({
    if(is.na(input$pasteURL)) {return()} else{
      
      #read html
      txt = read_html(input$pasteURL)
      #capture <title></title> and extract the text
      needed_title = txt %>% html_nodes("title") %>% html_text()
      #split the artist and title(song name)
      meta = unlist(strsplit(needed_title, split = " · ", fixed = T))
      artist = unlist(strsplit(meta[1], split = " - ", fixed = T))[1]
      song = unlist(strsplit(meta[1], split = " - ", fixed = T))[2]
      #get beatmap host name
      rawinfo = txt %>% html_nodes("script:contains('beatmaps')")
      info = rawinfo[2] %>% html_text()
      info2 = gsub("        ", "", gsub("\\{|\\}", "",
                                        gsub('\"', "'", gsub('\n', '', info))))
      host_start = unlist(gregexpr("'creator'", info2))
      host_end = unlist(gregexpr(",'favourite_count'", info2))
      
      #write the results (URL, artist and title)
      cat(paste(
        "URL:", input$pasteURL, "\nArtist:", artist,
        "\nTitle:", song, "\nBeatmap Host:", substr(
          info2, host_start+11, host_end-2), "\n\n"))
    }
    
  })
  
  output$view <- renderTable({
    if(is.na(input$pasteURL)) {return()} else{
      
      #read html
      txt = read_html(input$pasteURL)
      #find map/diff info(all diffs, play/passcounts, star ratings, etc)
      rawinfo = txt %>% html_nodes("script:contains('beatmaps')")
      info = rawinfo[2] %>% html_text()
      info2 = gsub("        ", "", gsub("\\{|\\}", "",
                                        gsub('\"', "'", gsub('\n', '', info))))
      mapinfo = unlist(strsplit(info2, split = "'beatmaps'", fixed = T))
      needed_map = unlist(strsplit(mapinfo[2],
                                   split = "'converts'", fixed = T))
      diffinfo = needed_map[1]
      #find the position of 'version', 'difficulty_rating'
      version_start = unlist(gregexpr("'version'", diffinfo))
      version_end = unlist(gregexpr(",'accuracy'", diffinfo))
      sr_start = unlist(gregexpr("'difficulty_rating'", diffinfo))
      sr_end = unlist(gregexpr(",'id'", diffinfo))
      pc_start = unlist(gregexpr("'playcount'", diffinfo))
      pc_end = unlist(gregexpr(",'ranked'", diffinfo))
      ps_start = unlist(gregexpr("'passcount'", diffinfo))
      ps_end = unlist(gregexpr(",'playcount'", diffinfo))
      
      rowname = c("Difficulty", "Star Rating", "Play Count",
                  "Pass Count", "Pass Ratio")
      diffmatrix = matrix(data = NA, nrow = 5, ncol = length(version_start),
                          dimnames = list(rowname))
      
      for (i in c(1:nrow(diffmatrix))) {
        for (j in c(1:ncol(diffmatrix))) {
          if(i == 1){ #diffnames
            diffmatrix[i,j] = substr(
              diffinfo, version_start[j]+11, version_end[j]-2)
          }
          if(i == 2){ #star ratings
            diffmatrix[i,j] = format(as.numeric(substr(
              diffinfo, sr_start[j]+20, sr_end[j]-1)), nsmall = 2)
          }
          if(i == 3){ #playcounts
            diffmatrix[i,j] = format(substr(
              diffinfo, pc_start[j]+12, pc_end[j]-1),
              nsmall = 0, big.mark = ",")
          }
          if(i == 4){ #passcounts
            diffmatrix[i,j] = format(substr(
              diffinfo, ps_start[j]+12, ps_end[j]-1),
              nsmall = 0, big.mark = ",")
          }
          if(i == 5){ #pass ratio
            diffmatrix[i,j] = round(as.numeric(substring(
              as.numeric(diffmatrix[4,j]) / as.numeric(diffmatrix[3,j]),
              1, 6)), digits = 3)
          }
        }
      }
      
      if(input$Sort == "sr"){
        if(input$ADE == "a"){
          print(t(diffmatrix[, str_order(diffmatrix[2,], numeric = T)]))
        }
        else if(input$ADE == "de"){
          print(t(diffmatrix[, str_order(diffmatrix[2,],
                                         decreasing = T, numeric = T)]))
        }
        else {return()}
        
      } else if(input$Sort == "pc"){
          if(input$ADE == "a"){
            print(t(diffmatrix[, str_order(diffmatrix[3,], numeric = T)]))
          }
          else if(input$ADE == "de"){
            print(t(diffmatrix[, str_order(diffmatrix[3,],
                                           decreasing = T, numeric = T)]))
          }
        else {return()}
        
      } else if(input$Sort == "ps"){
          if(input$ADE == "a"){
            print(t(diffmatrix[, str_order(diffmatrix[4,], numeric = T)]))
          }
          else if(input$ADE == "de"){
            print(t(diffmatrix[, str_order(diffmatrix[4,],
                                           decreasing = T, numeric = T)]))
          }
        else {return()}
        
      } else if(input$Sort == "passp"){
          if(input$ADE == "a"){
            print(t(diffmatrix[, str_order(diffmatrix[5,], numeric = F)]))
          }
          else if(input$ADE == "de"){
            print(t(diffmatrix[, str_order(diffmatrix[5,],
                                           decreasing = T, numeric = F)]))
          }
        else {return()}
        
      } else {return()}
    }
  })
})