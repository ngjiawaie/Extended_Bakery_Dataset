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
#install.packages("arules")
library(arules)
df_trans <- as(split(test_df$Food, test_df$Receipt_Number), "transactions")
df_trans_Flavor <- as(split(test_df$Flavor, test_df$Receipt_Number), "transactions")
df_trans_Type <- as(split(test_df$Type, test_df$Receipt_Number), "transactions")
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

#start timer
ptm <- proc.time()
rules<-apriori(df_trans, 
               control=list(verbose=F),
               parameter=list(supp=0.015,conf=0.9))
rules.sorted <- sort(rules, by="lift")

#trying to remove redundancy
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

#part 2(Flavor)
#start timer
ptm <- proc.time()
rules2<-apriori(df_trans_Flavor, 
               control=list(verbose=F),
               parameter=list(supp=0.005,conf=0.7))
rules2.sorted <- sort(rules2, by="lift")

#trying to apply remove redundancy
subset.matrix <- is.subset(rules2.sorted, rules2.sorted)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA
redundant <- colSums(subset.matrix, na.rm=T) >= 1
which(redundant)

#remove redundant rules
rules2.pruned <- rules2.sorted[!redundant]
inspect(rules2.pruned)
rules2 <- rules2.pruned
inspect(rules2)

#end timer
proc.time() - ptm

#part 3(Type)
#start timer
ptm <- proc.time()
rules3<-apriori(df_trans_Type, 
                control=list(verbose=F),
                parameter=list(supp=0.010,conf=0.8))
rules3.sorted <- sort(rules3, by="lift")

#trying to apply remove redundancy
subset.matrix <- is.subset(rules3.sorted, rules3.sorted)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA
redundant <- colSums(subset.matrix, na.rm=T) >= 1
which(redundant)

#remove redundant rules
rules3.pruned <- rules3.sorted[!redundant]
inspect(rules3.pruned)
rules3 <- rules3.pruned
inspect(rules3)

#end timer
proc.time() - ptm

#Visualize
install.packages("arulesViz")
library(arulesViz)

#trying plot to see what kind of results that we might expected
plot(rules)
plot(rules, measure=c("support","lift"), shading="confidence")

#trying to find out more about the high lift and high confidence item
sel = plot(rules, method="grouped", interactive=TRUE)

#hmm the data visualization seem to be too untidy, we only interested in the top 10 lift itemsets
subrules = head(sort(rules, by="lift"), 10)
plot(subrules)
plot(subrules, method="graph", control=list(type="items"))
plot(subrules, method="matrix", measure=c("lift"), control=list(main="Top 10 Lift Itemsets"))

#flavor rule, trying to see what can we get from rules 2
plot(rules2, measure=c("support","lift"), shading="confidence")

#trying to find out what is the high lift and high confidence flavor, since it is not huge, there is no need to filter it first
plot(rules2, method="grouped", interactive=TRUE)
plot(rules2, method="graph", control=list(type="items"))
plot(rules2, method="matrix", measure=c("lift"), control=list(main="Flavor According to Lift"))

#type rule, trying to see what can we get from rule 3
plot(rules3, measure=c("support","lift"), shading="confidence")
#trying to find out what is the high lift and high confidence food type, since it is not huge, there is no need to filter it first
plot(rules3, method="grouped", interactive=TRUE)
plot(rules3, method="graph", control=list(type="items"))
plot(rules3, method="matrix", measure=c("lift"), control=list(main="Food Type According to Lift"))

#type <- receipt_df[receipt_df$Type=="Croissant",]
#ggplot(type, aes(x = factor(1), fill = factor(type$Flavor)))+ geom_bar(width = 1) + coord_polar(theta = "y")
