id <- c(0:49)
food <- c("Chocolate Cake","Lemon Cake","Casino Cake","Opera Cake", "Strawberry Cake", "Truffle Cake", "Chocolate Eclair", "Coffee Eclair", "Vanilla Eclair", "Napolean Cake", "Almond Tart", "Apple Pie", "Apple Tart","Apricot Tart", "Berry Tart", "Blackberry Tart", "Blueberry Tart", "Chocolate Tart", "Cherry Tart", "Lemon Tart", "Pecan Tart", "Ganache Cookie", "Gongolais Cookie", "Raspberry Cookie", "Lemon Cookie", "Chocolate Meringue", "Vanilla Meringue", "Marzipan Cookie", "Tuile Cookie", "Walnut Cookie", "Almond Croissant", "Apple Croissant", "Apricot Croissant", "Cheese Croissant", "Chocolate Croissant", "Apricot Danish", "Apple Danish", "Almond Twist", "Almond Bear Claw", "Blueberry Danish", "Lemonade", "Raspberry Lemonade", "Orange Juice", "Green Tea", "Bottled Water", "Hot Coffee", "Chocolate Coffee", "Vanilla Frappucino", "Cherry Soda", "Single Espresso")

df <- data.frame(id,food)

#Choose 1000i.csv
receipt_df <- read.csv("1000i.csv", header = F)
names(receipt_df) <- c("Receipt_Number","Quantity","Food")
#Choose 1000-out1.csv
sparse_df <- read.csv("1000-out1.csv", header = F, na.strings = "")
names(sparse_df) <- c("Receipt_Number", "Food_Num_1", "Food_Num_2", "Food_Num_3","Food_Num_4","Food_Num_5","Food_Num_6")
#Choose 1000-out2.csv
full_binary_df <- read.csv("1000-out2.csv", header = F)
names(full_binary_df) <- c("Receipt_Number", c(0:49))
#Map food id to food
receipt_df$Food <- df$food[match(receipt_df$Food,df$id)]
sparse_df$Food_Num_1 <- df$food[match(sparse_df$Food_Num_1,df$id)]
sparse_df$Food_Num_2 <- df$food[match(sparse_df$Food_Num_2,df$id)]
sparse_df$Food_Num_3 <- df$food[match(sparse_df$Food_Num_3,df$id)]
sparse_df$Food_Num_4 <- df$food[match(sparse_df$Food_Num_4,df$id)]
sparse_df$Food_Num_5 <- df$food[match(sparse_df$Food_Num_5,df$id)]
sparse_df$Food_Num_6 <- df$food[match(sparse_df$Food_Num_6,df$id)]
names(full_binary_df) <- c("Receipt_Number", as.character(df$food))
receipt_df$Receipt_Number <- as.factor(receipt_df$Receipt_Number)
test_df <- receipt_df[,c("Receipt_Number","Food")]
install.packages("arules")
library(arules)
df_trans <- as(split(test_df$Food, test_df$Receipt_Number), "transactions")
#------------------------------------------------------------------End of Data Preparation

#Trying to know more about the data
library(ggplot2)
reorder_size <- function(x) {
  factor(x, levels = names(sort(table(x))))
}
#Initial Plot
ggplot(data = receipt_df, aes(x = reorder_size(Food), fill = as.factor(Quantity))) + geom_bar(colour = "black") + coord_flip()
#Plot using facet, foods that is bought in different quantity is visualized in different charts
ggplot(data = receipt_df, aes(x = reorder_size(Food), fill = as.factor(Quantity))) + geom_bar(colour = "black") + facet_grid(as.factor(Quantity)~.) + theme(axis.text.x = element_text(angle = 90, hjust = 1))

#-----------Converting csv files to transaction/ market basket format for apriori analysis
#write.csv(receipt_df, "output.csv", row.names = F)
#required_Data<-read.transactions("output.csv", rm.duplicates=TRUE, format = "basket")
#----------required_Data should be ready for apriori by now.

#-----------------------------------------Psst, dun ask y
#start timer
ptm <- proc.time()
rules<-apriori(df_trans, 
               control=list(verbose=F),
               parameter=list(supp=0.015,conf=0.9))
rules.sorted <- sort(rules, by="lift")

#trying to apply remove redundancy
subset.matrix <- is.subset(rules.sorted, rules.sorted)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA
redundant <- colSums(subset.matrix, na.rm=T) >= 1
which(redundant)

#remove redundant rules
rules.pruned <- rules.sorted[!redundant]
inspect(rules.pruned)
rules <- rules.pruned
inspect(rules)

#end timer
proc.time() - ptm

#Visualize
install.packages("arulesViz")
library(arulesViz)

#trying plot to see what kind of results that we might expected
plot(rules)
plot(rules, measure=c("support","lift"), shading="confidence");

#trying to find out more about the high lift and high confidence item
sel = plot(rules, method="grouped", interactive=TRUE);

#hmm the data visualization seem to be too untidy, we only interested in the top 10 lift itemsets
subrules = head(sort(rules, by="lift"), 10)
plot(subrules)
plot(subrules, method="graph", control=list(type="items"))
plot(subrules, method="matrix", measure=c("lift"), control=list(main="Top 10 Lift Itemsets"))




