library(shiny)

shinyUI(pageWithSidebar(
  
  headerPanel("CheckOsuMapInfo"),
  
  sidebarPanel(
    textInput("pasteURL", "paste URL here:", value = ""),
    helpText("e.g. https://osu.ppy.sh/beatmapsets/xxxxxxx"),
    radioButtons("Sort", "Sort by star rating or playcount:",
                 choices = c("Star Rating" = "sr", "Playcount" = "pc",
                             "Passcount" = "ps", "Pass Ratio" = "passp")
                 ),
    radioButtons("ADE", "Ascending or Descending:",
                 choices = c("Ascending" = "a", "Descending" = "de")),
    p("Created by MarioUniverseZ", br(),
      a("osu! userpage", href = "https://osu.ppy.sh/users/12395688"), br(),
      a("GitHub repo page", href = "https://github.com/MarioUniverseZ/CheckOsuMapInfo"))
  ),
  
  mainPanel(
    verbatimTextOutput("URL"),
    tableOutput("view")
  )
  
))