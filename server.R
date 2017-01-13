library(shiny)
library(ggplot2)
library(arules)
library(arulesViz)

id <- c(0:49)
food <- c("Chocolate Cake","Lemon Cake","Casino Cake","Opera Cake", "Strawberry Cake", "Truffle Cake", "Chocolate Eclair", "Coffee Eclair", "Vanilla Eclair", "Napolean Cake", "Almond Tart", "Apple Pie", "Apple Tart","Apricot Tart", "Berry Tart", "Blackberry Tart", "Blueberry Tart", "Chocolate Tart", "Cherry Tart", "Lemon Tart", "Pecan Tart", "Ganache Cookie", "Gongolais Cookie", "Raspberry Cookie", "Lemon Cookie", "Chocolate Meringue", "Vanilla Meringue", "Marzipan Cookie", "Tuile Cookie", "Walnut Cookie", "Almond Croissant", "Apple Croissant", "Apricot Croissant", "Cheese Croissant", "Chocolate Croissant", "Apricot Danish", "Apple Danish", "Almond Twist", "Almond Bear_Claw", "Blueberry Danish", "Lemon Lemonade", "Raspberry Lemonade", "Orange Juice", "Green Tea", "Bottled Water", "Hot Coffee", "Chocolate Coffee", "Vanilla Frappucino", "Cherry Soda", "Single Espresso")

df <- data.frame(id, food)

#Choose 1000i.csv
receipt_df <- read.csv("1000i.csv", header = F)
names(receipt_df) <- c("Receipt_Number","Quantity","Food")

#Map food id to food
receipt_df$Food <- df$food[match(receipt_df$Food,df$id)]

Flavor <- matrix(unlist(strsplit(as.character(receipt_df$Food), ' ')) , ncol=2, byrow=TRUE)
receipt_df <- data.frame(receipt_df, Flavor)
names(receipt_df) <- c("Receipt_Number","Quantity","Food", "Flavor", "Type")


test_df <- receipt_df[,c("Receipt_Number","Food", "Flavor", "Type")]
typeof(test_df)

df_trans <- as(split(test_df$Food, test_df$Receipt_Number), "transactions")
df_trans_Flavor <- as(split(test_df$Flavor, test_df$Receipt_Number), "transactions")
df_trans_Type <- as(split(test_df$Type, test_df$Receipt_Number), "transactions")
#------------------------------------------------------------------End of Data Preparation


shinyServer(function(input, output) {
  
  output$bar<- renderPlot({
    
    reorder_size <- function(x) {
      factor(x, levels = names(sort(table(x))))
    }
    #Initial Plot
    if(input$TypeOfGraph == "Basic Data Plot"){
      ggplot(data = receipt_df, aes(x = reorder_size(Food), fill = as.factor(Quantity))) + geom_bar(colour = "black") + coord_flip()
    }
    #Plot using facet, foods that is bought in different quantity is visualized in different charts
    else if(input$TypeOfGraph == "Basic Data Plot with facet"){
    ggplot(data = receipt_df, aes(x = reorder_size(Food), fill = as.factor(Quantity))) + geom_bar(colour = "black") + facet_grid(as.factor(Quantity)~.) + theme(axis.text.x = element_text(angle = 90, hjust = 1))
    }
    
  })
  output$plot<- renderPlot({
    ##remove redundant
    df_trans_sel <- df_trans
    if(input$TypeOfData == "Food"){
      df_trans_sel <- df_trans
    }
    else if(input$TypeOfData == "Flavor"){
      df_trans_sel <- df_trans_Flavor
    }
    else if(input$TypeOfData == "Type of Food"){
      df_trans_sel <- df_trans_Type
    }
    beginning <- Sys.time()
    rules<-apriori(df_trans_sel, 
                   control=list(verbose=F),
                   parameter=list(supp=input$supp_value,conf=input$conf_value))
    rules.sorted <- sort(rules, by="lift")
    subset.matrix <- is.subset(rules.sorted, rules.sorted)
    subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA
    redundant <- colSums(subset.matrix, na.rm=T) >= 1
    rules.pruned <- rules.sorted[!redundant]
    rules <- rules.pruned
    
    #trying plot to see what kind of results that we might expected
    subrules <- rules
    if(input$lift_control == TRUE){
      subrules = head(sort(rules, by="lift"), input$lift_value)
    }
    if(input$TypeOfPlot == "Scatter(Lift as parameter)"){
      plot(subrules, measure=c("support","lift"), shading="confidence")
    }
    #trying to find out more about the high lift and high confidence item
    else if(input$TypeOfPlot == "Grouped"){
      plot(subrules, method="grouped")
    }  
    else if(input$TypeOfPlot == "Graph"){
      plot(subrules, method="graph")
    } 
    else if(input$TypeOfPlot == "Scatter"){
      plot(subrules, method="scatterplot")
    } 
    else if(input$TypeOfPlot == "Parallel Coordinates"){
      plot(subrules, method="paracoord")
    } 
    else if(input$TypeOfPlot == "Matrixs"){
      plot(subrules, method="matrix", measure=c("lift"))
    }
    end <- Sys.time()  
    print(end - beginning)
  })

  
})
