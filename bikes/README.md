
# Outlook of bike rentals in Chicago area

# Overview 
Rental bikes become more and more widespread around the world. 
This interactive dashboard is intendent 
to give you insights regarding bikes rent in Chicago in April 2020.
This data was analyzed using SQL and visualized in Tableau. The results and
recommendations regarding business strategy are summarized in 
Results section.

# Motivation
Bike rental companies spend a lot of money to maintain bikes quality and ensure the
minimal amortization costs. 
The aim of this work 
is to identify users who travelled the longest distance within a 
single ride because the more you travel the more money you pay
for a rent of a bike. Also, frequent bikes switching may lead to the 
increase in expenditure related to the bikes amortization cost and 
the increase in bikes downtimes (the time
when bikes are not in use).





# Demo
**Chicago area bikes trips starting points**

![image](https://user-images.githubusercontent.com/71885827/189534271-4022b94e-7d61-4409-8895-2e2afda5d5c1.png)



**Number of bikers during a day (within 24 hours)**
![image](https://user-images.githubusercontent.com/71885827/189534389-da9a2dba-d318-4777-9642-e10b8b6de3a1.png)



**Link for Tableau Viz is [here](https://public.tableau.com/app/profile/valery.li8566/viz/Chicagorentalbikesanalysis/Dashboard1)**


## Authors

- [@Valery Liamtsau](https://www.linkedin.com/in/valery-liamtsau/)


## Results

1. Membership discounts do not increase the bike usage time. 
The number of members is about **3 times more than the 
number of casual users**, however the average trips time was about 
the same for these two categories. Membership  leads to the increase 
in popularity of bikes, however it is not very clear how
many bikers are attracted by the membership coupons (this
information is missing and needs to be investigated once obtained). The revenue is clearly
dependent upon the longevity of a trip. 
There might other factors as well, however at this  moment
 **the implementation
of price discounts should be reconsidered**.

2. Analyzing the average count of trips during the day it was 
found that there are two peaks and 2 lows of bikes usage.

Peaks: 

a) During midday and afternoon, which is reasonable (midday commuting)

b) During the first hour of the night, which is unexpected and needsto be 
investigated further.

Lows:

a) During early morning from 4 am to 8 am, which is reasonable (sleeping time)

b) During the evening from 6 pm, which unexpected (**MUST BE IMPROVED**)

**Recommendation:
price discounts may be issued based on the day time, especially for
evening periods because the number of users for these times was relatively 
small (around 12 000 trips)**.

3. Wednesday is the day with the lowest number of trips (9 000), while the weekend was as expected the most popular (18 000). Interestingly,  the number of trips on Tuesday was by 60% higher
than on Wednesday

**Recommendation:
price discounts may be given for the middle 
of the week**.









If you have any feedback, please reach out to us at 
valery.liamtsau@aol.com


## Acknowledgements


 - I need to thank [MICHAEL SHOEMAKER](https://www.kaggle.com/datasets/michaelshoemaker/divvy-bike-chicago-2018) for providing me with this beautiful dataset
 

