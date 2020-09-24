library(shiny)
library(ggplot2)
library(dplyr)
library(tidyr)
library(lubridate)

reticulate::virtualenv_create(envname = "python_environment", python= "python3")
reticulate::virtualenv_install("python_environment", packages = c('psaw', 'praw','pandas','datetime'))
reticulate::use_virtualenv("python_environment", required = TRUE)

library(reticulate)

# UI for app
ui<-(pageWithSidebar(
  # title
  headerPanel("Enter Subreddit and Dates"),
  
  #input
  sidebarPanel
  (
    textInput("caption", "Subreddit Name", "CourageTheCowardlyDog"),
    textInput("startDate","Start Date", "1/1/2019"),
    textInput("endDate", "End Date", "6/30/2019"),
    actionButton("do_query", "Click to Query Data"),
    selectInput("plot_type", "What do you want to plot?", 
                c("Total Comments Per Month", 
                  "Unique Commentors Per Month", 
                  "Active Threads Per Month",
                  "Total Comments Per User")),
    actionButton("do_plot", "Click to Plot Data")
  ),
  
  # output
  mainPanel(
    plotOutput("plot")
  )
))


# shiny server side code for each call
server<-(function(input, output){
  df <- reactiveValues(comments = data.frame(), threads = data.frame())
 
  observeEvent(input$do_query,{
    withProgress(message = "Loading Data", value = 0, {
    req(input$caption)
    req(input$startDate)
    req(input$endDate)
    tx  <- readLines("pull_data_generic.py")
    incProgress(1/4)
    tx2  <- gsub(pattern = "SUBREDDIT_NAME", replace = input$caption, x = tx)
    tx3  <- gsub(pattern = "START_YEAR", replace = year(mdy(input$startDate)), x = tx2)
    tx4  <- gsub(pattern = "START_MONTH", replace = month(mdy(input$startDate)), x = tx3)
    tx5  <- gsub(pattern = "START_DAY", replace = day(mdy(input$startDate)), x = tx4)
    tx6  <- gsub(pattern = "END_YEAR", replace = year(mdy(input$endDate)), x = tx5)
    tx7  <- gsub(pattern = "END_MONTH", replace = month(mdy(input$endDate)), x = tx6)
    tx8  <- gsub(pattern = "END_DAY", replace = day(mdy(input$endDate)), x = tx7)
    incProgress(1/4)
    writeLines(tx8, con="pull_data_specific.py")
    source_python("pull_data_specific.py")
    incProgress(1/4)
    df$comments <- comment_data
    df$threads <- thread_data
    incProgress(1/4)
    })
  })
  
  observeEvent(input$do_plot,{ 
  output$plot <- renderPlot({
    withProgress(message = "Loading Plot", value = 0, {  
    incProgress(1/3)  
    if(input$plot_type == "Total Comments Per Month") {
        df_all <- bind_rows(df$comments[,c("author", "timestamp")], df$threads[,c("author", "timestamp")])
        df_all$MMYY <- format(as.POSIXct(df_all$timestamp), "%Y-%m")
        df2 <- df_all %>% group_by(MMYY) %>% tally()
        incProgress(1/3)
        ggplot(df2, aes(x = MMYY, y = n, group = 1)) +
          geom_line(linetype = "dashed", color = "blue") +
          geom_point(color = "blue") +
          labs(title = "Number of Total Comments per Month", x = "Month", y = "Number of Total Comments")
    }
    else if (input$plot_type == "Unique Commentors Per Month") {
        df_all <- bind_rows(df$comments[,c("author", "timestamp")], df$threads[,c("author", "timestamp")])
        df_all$MMYY <- format(as.POSIXct(df_all$timestamp), "%Y-%m")
        df2 <- df_all %>% group_by(MMYY, author) %>% tally() %>% group_by(MMYY) %>% tally()
        incProgress(1/3)
        ggplot(df2, aes(x = MMYY, y = n, group = 1)) +
          geom_line(linetype = "dashed", color = "blue") +
          geom_point(color = "blue") +
          labs(title = "Number of Unique Commentors per Month", x = "Month", y = "Number of Unique Commentors")
    }
    else if (input$plot_type == "Active Threads Per Month") {
        df_threads <- df$threads
        df_threads$MMYY <- format(as.POSIXct(df_threads$timestamp), "%Y-%m")
        df2 <- df_threads %>% group_by(MMYY) %>% tally()
        incProgress(1/3)
        ggplot(df2, aes(x = MMYY, y = n, group = 1)) +
          geom_line(linetype = "dashed", color = "blue") +
          geom_point(color = "blue") +
          labs(title = "Number of Active Threads per Month", x = "Month", y = "Number of Active Threads")
    }
    else if (input$plot_type == "Total Comments Per User") {
        df_all <- bind_rows(df$comments["author"], df$threads["author"])
        df2 <- df_all %>% group_by(author) %>% tally()
        df3 <- df2[order(-df2$n), ]
        incProgress(1/3)
        ggplot(df3, aes(x = reorder(author, desc(n)), y = n, group = 1)) +
          geom_line(color = "blue") + geom_point(color = "blue") +
          labs(title = "Number of Total Comments per User", x = "User", y = "Number of Comments") +
          theme(axis.text.x=element_blank(),axis.ticks.x=element_blank())
    }
    })
  })
})
})

shinyApp(ui, server)
