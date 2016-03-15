library(shiny)
library(magrittr)
library(RSQLite)
library(DBI)
source('/home/longyi/shinyapps/apps/twitterParis/oauth.R')
setwd("/home/longyi/data/tweets")
con <- dbConnect(RSQLite::SQLite(), "tweets.sqlite")
register_db_backend(con)


ui <- shinyServer(fluidPage(
  titlePanel("Tweets collection - #ParisAttacks "),
  plotOutput("myplot", height = 800)
  
))

server <- shinyServer(function(input, output, session){
  # Function to get new observations
  get_new_data <- function(){
    seconds <- round(as.numeric(Sys.time() - start, units= "mins"))
    newT <- search_twitter_and_store("#ParisAttacks", table_name = "tweets", lang ='en')
    totalT <<- totalT + newT
    data <- c(seconds, newT, totalT) # %>% rbind %>% data.frame
    return(data)
  }
  
  # Initialize my_data
  # my_data <- get_new_data()
  start <- Sys.time()
  seconds <- round(as.numeric(Sys.time() - start, units= "mins"))
  totalT <- nrow(dbReadTable(con, "tweets"))
  my_data <- data.frame(time = seconds, newTweets = 0, allTweets = totalT)
  
                        
  # Function to update my_data
  update_data <- function(){
    my_data <<- rbind(get_new_data(), my_data)
  }
  
  # Plot the most recent values
  output$myplot <- renderPlot({
    # print("Render")
    invalidateLater(60000, session)
    update_data()
    # print(my_data[1:5,])
    par(mfrow=c(2,1)) 
    plot(newTweets ~ time, data = my_data[1:30,], las = 1, 
         type = "b", main = "New Tweets Collected",
         xlab = "time (minutes)")
    plot(allTweets ~ time, data = my_data[1:30,], las = 1, 
         type="b", main = "Total Tweets in Database",
         xlab = "time (minutes)")
  })
  

})

shinyApp(ui=ui,server=server)
