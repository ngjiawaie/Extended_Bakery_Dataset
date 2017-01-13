## Question
### 1. Objective
This dataset records information about sales for a bakery shop. By doing association rule mining, we can improve business sales by uncovering relationships between items sold in the bakery. For instance, we can discover what item are usually sold together and hence making business decisions based on these associations.

### 2. Dataset description
<p>The dataset contains transactions made by customers and each transaction hold records of item(s) sold and its quantity sold.</p>
#### Data preprocessing done:

* Quantity column is omitted from the dataset as quantity of purchase will not affect the outcome gain from association rule mining.
* Each integer representation of Food column into mapped into its text representation that are more meaningful.
    + This is done so that when doing association rule mining or even when visualizing the data, everything          will be more obvious. 
* Header names are added to each of the columns of the dataset so that we can correctly differentiate between columns. 
* Data is converted into basket format so that we can run it in apriori.

### 3. Rule mining process
Parameter Settings (Based on 1000i.csv)
<table>
| Parameter     | Value         |
|---------------|---------------|
| Support       | 0.015         |
| Confidence    | 0.9           |
| Algorithm     | apriori       |
| Time required | 0.20s - 0.24s |
</table>

### 4. Resulting rules
This association rule mining tells us which item are normally sold with other items. <br>
After pruning the rules, we are left with 28 rules. (Was 68 before pruning) <br><br>
<p>A summary of the rules (Pruned) </p>
<table>
| Description       | Value  |
|-------------------|--------|
|minimum support    | 0.018  |
|maximum support    | 0.040  |
|minimum confidence | 0.9    |
|maximum confidence | 1.0    |
|minimum lift       | 11.18  |
|maximum lift       | 19.61  |
</table>

### 5. Recommendations
Clients can do bundled promotions based on the rules discovered. <br>
The rules has shown that those who like coffee flavor will also favor blackberry flavor. Hence we can conclude that customers enjoy the combination of these flavors as their meals. The recommendation that we can give to the client is, try to make a bundle based on the combination of flavor of the menu. Besides that, those who buy vanilla frappucino and walnut cookie are likely to buy chocolate tart. Hence the client can sell these in a bundle. Clients can also do discounts and promotion on items that are frequently bought together. For instance, Those who buy coffee drink can get discounted price for eclair,pie or twist.
