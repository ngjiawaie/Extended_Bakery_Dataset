id <- c(0:49)
food <- c("Chocolate Cake","Lemon Cake","Casino Cake","Opera Cake", "Strawberry Cake", "Truffle Cake", "Chocolate Eclair", "Coffee Eclair", "Vanilla Eclair", "Napolean Cake", "Almond Tart", "Apple Pie", "Apple Tart","Apricot Tart", "Berry Tart", "Blackberry Tart", "Blueberry Tart", "Chocolate Tart", "Cherry Tart", "Lemon Tart", "Pecan Tart", "Ganache Cookie", "Gongolais Cookie", "Raspberry Cookie", "Lemon Cookie", "Chocolate Meringue", "Vanilla Meringue", "Marzipan Cookie", "Tuile Cookie", "Walnut Cookie", "Almond Croissant", "Apple Croissant", "Apricot Croissant", "Cheese Croissant", "Chocolate Croissant", "Apricot Danish", "Apple Danish", "Almond Twist", "Almond Bear Claw", "Blueberry Danish", "Lemonade", "Raspberry Lemonade", "Orange Juice", "Green Tea", "Bottled Water", "Hot Coffee", "Chocolate Coffee", "Vanilla Frappucino", "Cherry Soda", "Single Espresso")

df <- data.frame(id,food)

#Choose 1000i.csv
receipt_df <- read.csv(file.choose(), header = F)
names(receipt_df) <- c("Receipt_Number","Food_Number","Quantity")
#Choose 1000-out1.csv
sparse_df <- read.csv(file.choose(), header = F, na.strings = "")
names(sparse_df) <- c("Receipt_Number", "Food_Num_1", "Food_Num_2", "Food_Num_3","Food_Num_4","Food_Num_5","Food_Num_6")
#Choose 1000-out2.csv
sparse_df <- read.csv(file.choose(), header = F)
names(sparse_df) <- c("Receipt_Number", c(0:49))
