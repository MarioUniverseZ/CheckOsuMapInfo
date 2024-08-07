library(shiny)
library(rvest)
library(stringr)

shinyServer(function(input, output) {
  
  output$URL <- renderPrint({
    if(is.na(input$pasteURL)) {return()} else{
      
      tryCatch({
        
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
        
      }, error = function(err){cat("")})
      
    }
    
  })
  
  output$view <- renderTable({
    if(is.na(input$pasteURL)) {return()} else{
      
      tryCatch({
        
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
        
        fail_start = unlist(gregexpr("'fail'", diffinfo))
        fail_end = unlist(gregexpr(",'exit'", diffinfo))
        exit_start = unlist(gregexpr("'exit'", diffinfo))
        exit_end = unlist(gregexpr(",'max_combo'", diffinfo))
        
        hitlength_start = unlist(gregexpr("'hit_length'", diffinfo))
        hitlength_end = unlist(gregexpr(",'is_scoreable'", diffinfo))
        
        rowname = c("Difficulty", "Star Rating", "Play Count",
                    "Pass Count", "Pass Ratio", "Hard Parts",
                    "Annoying Parts")
        diffmatrix = matrix(data = NA, nrow = length(rowname),
                            ncol = length(version_start),
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
            if(i == 6){ #fail, show top 5 hardest parts
              hitlength = as.numeric(substr(
                diffinfo, hitlength_start[j]+13, hitlength_end[j]-1))
              fail = as.numeric(unlist(strsplit(substr(
                diffinfo, fail_start[j]+8, fail_end[j]-2), ",")))
              sorted = order(fail, decreasing = TRUE)
              place = format(
                as.POSIXct(
                  "1970-01-01"
                ) + (hitlength * (sorted[1:5] / 100)),
                "%M:%S"
              )
              diffmatrix[i,j] = paste(place, collapse = ", ")
            }
            if(i == 7){ #exit, show top 5 the most annoying parts
              hitlength = as.numeric(substr(
                diffinfo, hitlength_start[j]+13, hitlength_end[j]-2
              ))
              exit = as.numeric(unlist(strsplit(substr(
                diffinfo, exit_start[j]+8, exit_end[j]-2), ",")))
              sorted = order(exit, decreasing = TRUE)
              place = format(
                as.POSIXct(
                  "1970-01-01"
                ) + (hitlength * (sorted[1:5] / 10)),
                "%M:%S"
              )
              diffmatrix[i,j] = paste(place, collapse = ", ")
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
      }, error = function(err2){cat("")})
    }
  })
})