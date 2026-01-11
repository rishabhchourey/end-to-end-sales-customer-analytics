import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import mysql.connector


conn = mysql.connector.connect(
    host="127.0.0.1",
    user="root",
    password="Rish@123",
    database="local_business_analytics"
)


query = """
SELECT
    o.order_id,
    o.order_date,
    o.quantity,
    o.price,
    (o.quantity * o.price) AS total_amount,
    c.customer_id,
    c.customer_name,
    c.age,
    c.city,
    pay.payment_mode,
    pay.payment_status,
    f.rating
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN payments pay ON o.order_id = pay.order_id
LEFT JOIN feedback f ON o.order_id = f.order_id
"""


df = pd.read_sql(query, conn)
df.info()


df.head()
df.info()

df.isnull().sum()

df['rating'] = df['rating'].fillna(df['rating'].mean())

df['order_date'] = pd.to_datetime(df['order_date'])


# TOTAL REVENUE 

total_revenue = df['total_amount'].sum()
print("Total Revenue:", total_revenue)       # OUTPUT: Total Revenue: 62274666


# MONTHLY REVENUE

monthly_revenue = (
    df.groupby(df['order_date'].dt.to_period('M'))['total_amount']
    .sum()
)

print(monthly_revenue)

#OUTPUT:
# 2025-02    3950311
# 2025-03    4047185
# 2025-04    2912332
# 2025-05    3245934
# 2025-06    1113032
# 2025-07    2367293
# 2025-08    2724970
# 2025-09    1597018
# 2025-10    4018095
# 2025-11    2649576
# 2025-12    1372438



# TOP CUSTOMERS

top_customers = (
    df.groupby('customer_name')['total_amount']
    .sum()
    .sort_values(ascending=False)
    .head(10)
)

print(top_customers)

# customer_name
# Kavita Solanki      2126666
# Deepika Deshmukh    1595750
# Sumit Ghosh         1593709
# Bina Mishra         1576499
# Namita Roy          1482700
# Bhavana Arora       1476594
# Shruti Dutta        1428764
# Sachin Desai        1406961
# Ayesha Ghosh        1362850
# Manoj Luthra        1320664



# PAYMENT STATUS

df['payment_status'] = df['payment_status'].fillna('Unknown')

payment_status = df['payment_status'].value_counts()
print(payment_status)

# OUTPUT: 
# payment_status
# Failed     180
# Success    169
# Unknown      1

# RATING VS REVENUE

df['rating'] = df['rating'].fillna(0)

rating_revenue = (
    df.groupby('rating')['total_amount']
    .sum()
)

print(rating_revenue)


# OUTPUT
# rating
# 2.000000     4186749
# 3.000000    11565787
# 4.000000     9876736
# 4.309456      190696
# 5.000000    36454698


#CITY WISE REVENUE

city_revenue = (
    df.groupby('city')['total_amount']
    .sum()
    .sort_values(ascending=False)
)

print(city_revenue)

# OUTPUT:
# city
# Delhi         16124931
# Mumbai        13887969
# Ludhiana       5575671
# Madurai        3728600
# Chennai        3713964
# Kanpur         3171447
# Kolkata        2875863
# Gorakhpur      2851255
# Indore         2126666
# Coimbatore     1541865
# Rajkot         1187242
# Lucknow        1135535
# Patna          1028492
# Bhopal          917046
# Hyderabad       905691
# Ranchi          844317
# Vadodara        509524
# Jodhpur         148588

