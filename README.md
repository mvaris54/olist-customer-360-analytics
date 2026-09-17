# Olist Customer 360 — RFM Segmentation & Churn Analysis

**By Mohammad Varish | Data Analyst Portfolio Project**

An end-to-end **customer analytics project** using the Olist Brazilian E-Commerce dataset to analyze **96,000+ customers and 99,000+ orders**, identify high-value and at-risk customer segments, evaluate churn patterns, and uncover revenue and customer-experience opportunities.

The project combines **Excel/Power Query, Python, MySQL, and Power BI** to demonstrate a complete data analytics workflow — from data cleaning and validation to business insights and interactive dashboarding.

---

## Business Problem

E-commerce businesses need to understand:

1. Which customers generate the most value?
2. Which customers are at risk of becoming inactive?
3. How can customer segments be targeted differently?
4. How do delivery performance and customer satisfaction relate?
5. Where are revenue and growth opportunities concentrated?

This project addresses these questions through **RFM segmentation, churn analysis, customer behavior analysis, cohort retention, operational analysis, and revenue concentration analysis**.

---

## Dataset

**Source:** [Olist Brazilian E-Commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

| Attribute        | Details                       |
| ---------------- | ----------------------------- |
| Dataset          | Olist Brazilian E-Commerce    |
| Tables           | 9 relational tables           |
| Order Items      | 118,763+                      |
| Unique Customers | 96,095+                       |
| Time Period      | September 2016 – October 2018 |
| Geography        | Brazil                        |
| States           | 27                            |

The original dataset contains information about customers, orders, order items, products, sellers, payments, reviews, and geographic locations.

---

## Tech Stack

| Tool                     | Purpose                                                        |
| ------------------------ | -------------------------------------------------------------- |
| **Excel / Power Query**  | Data cleaning, transformation, merging and ETL                 |
| **Python**               | Data analysis, RFM segmentation, churn analysis and validation |
| **Pandas / NumPy**       | Data manipulation and analytical calculations                  |
| **Matplotlib / Seaborn** | Exploratory data visualization                                 |
| **MySQL**                | Business analysis and SQL validation                           |
| **Power BI**             | Interactive dashboard, DAX measures and drill-through analysis |

---

## Project Workflow

```text
Raw Olist Data
      ↓
Excel / Power Query
      ↓
Data Cleaning & Transformation
      ↓
Python Analysis
      ↓
RFM Segmentation & Churn Analysis
      ↓
MySQL Business Analysis & Validation
      ↓
Power BI Dashboard
      ↓
Business Insights & Recommendations
```

---

# 1. Data Cleaning & Preparation — Excel / Power Query

The original 9 relational tables were processed using Excel and Power Query.

### Key tasks

* Loaded and reviewed the 9 source tables
* Checked primary-key uniqueness and duplicate records
* Handled missing values based on business context
* Standardized date and categorical fields
* Merged relevant tables into an analytical dataset
* Created delivery-related features
* Prepared cleaned data for Python and SQL analysis

The final analytical dataset was designed around **customer, order and order-item level analysis**, while keeping data grain in consideration during aggregation.

---

# 2. Python Analysis

Python was used for customer-level analysis, segmentation and exploratory analysis.

### Key analysis performed

* Data type and date validation
* Customer-level aggregation
* Revenue and order analysis
* Average Order Value (AOV)
* Recency, Frequency and Monetary analysis
* RFM scoring using quartile-based segmentation
* Customer segmentation
* Churn analysis
* Repeat purchase analysis
* Cohort retention analysis
* Pareto / revenue concentration analysis
* Delivery delay analysis
* Customer review analysis
* Geographic analysis
* Product category analysis
* Payment behavior analysis

---

# 3. RFM Customer Segmentation

Customers were segmented using:

* **Recency** — how recently a customer purchased
* **Frequency** — how frequently a customer purchased
* **Monetary** — how much revenue a customer generated

The analysis created six business-oriented customer segments:

| Segment         | Customers | Revenue | Avg AOV |
| --------------- | --------: | ------: | ------: |
| Loyal Customers |    29,749 |  $4.27M |    $139 |
| Regular         |    17,825 |  $3.45M |    $194 |
| Cant Lose       |    11,970 |  $3.22M |    $252 |
| At-Risk         |    24,045 |  $2.64M |    $110 |
| Champions       |     6,308 |  $1.77M |    $257 |
| Hibernating     |     6,199 |  $0.38M |     $62 |

### Segment Interpretation

* **Champions** — highly valuable and recently active customers
* **Cant Lose** — historically valuable customers showing signs of inactivity
* **Loyal Customers** — established customers with consistent purchasing behavior
* **Regular** — customers with moderate purchasing activity
* **At-Risk** — customers showing declining or inactive behavior
* **Hibernating** — low-value customers with long periods of inactivity

---

# 4. Churn Analysis

A customer was classified as churned/inactive when they had **180+ days since their last purchase**, based on the project's defined analysis date.

### Key Findings

* **71.18%** of customers were classified as inactive
* **68,397** customers fell into the churned/inactive group
* Approximately **$11.07M** of historical revenue was associated with these customers
* The **Cant Lose** segment contains a significant group of historically valuable inactive customers
* At-Risk customers represent a large potential reactivation audience

> **Important:** Revenue associated with churned customers represents historical revenue generated by those customers, not guaranteed future revenue loss.

---

# 5. Repeat Purchase Analysis

The analysis shows a low repeat-purchase rate in the marketplace dataset.

### Key Findings

* **3.12% repeat purchase rate**
* Approximately **96.9% of customers were one-time buyers**
* Champions had the highest repeat-purchase rate at approximately **12.03%**

This highlights the importance of customer retention and reactivation strategies in a marketplace environment.

---

# 6. Customer Experience & Delivery Analysis

Delivery performance was analyzed against customer review scores.

### Key Findings

* **6.65% late delivery rate**
* Late-delivery orders received an average review score of approximately **2.27**
* On-time orders received an average review score of approximately **4.29**
* Difference: approximately **2.02 review points**
* Correlation between delivery delay and review score: approximately **−0.23**

The analysis indicates a **negative association between delivery delays and customer satisfaction**.

> Correlation indicates association, not causation.

---

# 7. Revenue Concentration — Pareto Analysis

Revenue concentration was analyzed to understand how much revenue is generated by the highest-value customers.

### Key Findings

* Top **10% of customers** contributed approximately **47.49% of revenue**
* Top **20% of customers** contributed approximately **61.89% of revenue**
* Approximately **41.77% of customers** were required to reach 80% of cumulative revenue

This demonstrates a strong concentration of revenue among a relatively smaller customer base.

---

# 8. Geographic Analysis

Customer and revenue distribution was analyzed across Brazilian states.

### Key Findings

* **São Paulo (SP)** contributed approximately **37.5% of total revenue**
* **SP, RJ and MG** together contributed more than **60% of revenue**
* Sellers were represented across **24 states**

The analysis highlights the concentration of marketplace activity in major Brazilian markets.

---

# 9. Product Category Analysis

Product-level revenue was analyzed to identify the highest-performing categories.

### Key Findings

| Rank | Category       |
| ---- | -------------- |
| 1    | health_beauty  |
| 2    | watches_gifts  |
| 3    | bed_bath_table |

* **health_beauty** generated approximately **$1.30M** in revenue
* The top 5 categories contributed approximately **55% of product revenue**

---

# 10. Payment Behavior

Payment methods and installment behavior were analyzed to understand customer purchasing patterns.

### Key Findings

* **Credit card:** approximately **78.88% of revenue**
* **Boleto:** approximately **18.23% of revenue**
* Customers using higher installment counts showed higher average order values in the analyzed data

---

# 11. SQL Business Analysis

MySQL was used to independently reproduce and validate key analytical calculations.

### SQL concepts used

* Aggregations
* `GROUP BY`
* `CASE`
* Subqueries
* CTEs
* Window functions
* `NTILE()`
* `ROW_NUMBER()`
* `LAG()`
* Customer-level calculations
* Revenue and retention analysis

Python and SQL results were cross-validated.

### Validation Note

Small differences can occur between Python and SQL RFM segmentation because:

* Python `qcut()` uses value-based quantile boundaries
* SQL `NTILE()` distributes ordered rows into buckets
* Ties in Frequency/Monetary values can therefore be assigned differently

This difference was investigated and documented rather than treating the outputs as automatically identical.

---

# 12. Power BI Dashboard

The final Power BI dashboard contains **5 analytical pages**.

### Page 1 — Executive Overview

* Revenue KPI
* Order KPI
* Customer KPI
* Monthly revenue trend
* Segment revenue
* Key business insights

### Page 2 — Customer 360 & RFM

* Customer segment distribution
* RFM analysis
* Churn analysis
* Repeat purchase behavior
* Segment-level KPIs

### Page 3 — Customer Experience & Operations

* Delivery performance
* Late vs on-time orders
* Review score comparison
* Delivery delay analysis
* Customer experience insights

### Page 4 — Product, Market & Sellers

* Top product categories
* Revenue by state
* Seller analysis
* Payment method analysis
* Market-level insights

### Page 5 — Customer Details

* Customer-level drill-through
* Customer purchase information
* RFM segment
* Revenue
* Order behavior
* Customer activity indicators

📸 Dashboard screenshots are available in the `/Screenshots` folder.

---

# Key Business Insights

### Customer Retention

A large proportion of customers are classified as inactive under the project's 180-day churn definition, while historically valuable customers exist within the inactive population.

### Revenue Concentration

The top 20% of customers contribute approximately 61.89% of revenue, showing that customer value is not evenly distributed.

### Customer Experience

Late deliveries are associated with substantially lower average review scores, making delivery performance an important operational metric to monitor.

### Repeat Purchases

The low repeat-purchase rate indicates that converting first-time buyers into repeat customers represents an important customer-retention opportunity.

### Geographic Concentration

São Paulo is the dominant revenue-generating state, with SP, RJ and MG together accounting for more than 60% of revenue.

### Product Concentration

A relatively small number of product categories account for a significant share of product revenue.

---

# Business Recommendations

## Customer Retention

* Develop loyalty initiatives for high-value active customers
* Use personalized offers for At-Risk customers
* Create targeted reactivation campaigns for historically valuable inactive customers
* Use customer segments to avoid applying the same campaign to every customer

## Reactivation

* Prioritize high-value inactive customers
* Use purchase history to recommend relevant product categories
* Test targeted incentives rather than applying broad discounts

## Operations

* Monitor late-delivery rates by seller and geography
* Investigate regions with consistently higher delivery delays
* Track delivery performance alongside customer review scores

## Product Strategy

* Monitor high-performing categories
* Explore cross-selling between complementary categories
* Use customer segments to personalize product recommendations

## Geographic Strategy

* Monitor performance in high-revenue states
* Identify secondary markets with growth potential
* Compare customer value and purchase behavior across regions

---

# Key Learnings

### 1. Data Grain Matters

Revenue calculated at order-item level can differ from order-level calculations. Aggregation must be performed at the correct grain to avoid double counting.

### 2. RFM Tie-Breaking Matters

Python `qcut()` and SQL `NTILE()` can produce slightly different segment assignments when many customers have identical values.

### 3. Churn Definition Matters

A 180-day inactivity threshold is an analytical definition, not proof that a customer will never return.

### 4. Correlation ≠ Causation

The negative relationship between delivery delay and review score indicates association, but does not by itself establish that delivery delay causes lower ratings.

### 5. Cross-Validation Improves Reliability

Using Python and SQL to independently validate important metrics helped identify and investigate differences before dashboard development.

---

# Repository Structure

```text
Olist-Customer-360/
│
├── 01_Notebook/
│   └── 360_project.ipynb
│
├── 02_Cleaned_Data/
│   └── Cleaned analytical data
│
├── SQL/
│   └── Business SQL queries
│
├── 04_Dashboard/
│   └── Power BI dashboard assets
│
├── Screenshots/
│   └── Dashboard screenshots
│
├── customer_360_master.csv
├── cohort_retention.csv
└── README.md
```

---

# Files Not Included

Some large files are intentionally excluded from the repository.

### Raw Dataset

The original Olist dataset can be downloaded from Kaggle:

[Olist Brazilian E-Commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

### Power BI File

The `.pbix` dashboard file is not included because of GitHub's individual file-size limitations.

Dashboard screenshots are provided in `/Screenshots`.

### Large Intermediate Files

Large intermediate files such as the merged Excel dataset and transaction-level CSV are excluded where necessary.

The repository focuses on keeping the **analysis notebook, SQL queries, final analytical outputs, and dashboard screenshots** available for review.

---

# How to Run

## Python

Open the Jupyter Notebook:

```bash
jupyter notebook 360_project.ipynb
```

The notebook contains the complete Python analysis workflow.

## MySQL

Open the SQL file and execute the business queries in MySQL:

```sql
SOURCE SQL/business_queries.sql;
```

## Power BI

Open the `.pbix` file in Power BI Desktop if available locally.

The repository also contains screenshots of all dashboard pages.

---

# Skills Demonstrated

**Data Analytics**

* Data Cleaning
* Data Transformation
* Exploratory Data Analysis
* Customer Segmentation
* RFM Analysis
* Churn Analysis
* Cohort Analysis
* Revenue Analysis
* Business Problem Solving

**Technical Skills**

* Excel
* Power Query
* Python
* Pandas
* NumPy
* MySQL
* Power BI
* DAX
* Data Visualization

**Business Skills**

* Customer Retention Analysis
* Revenue Concentration
* Customer Experience Analysis
* Operational Analysis
* Business Insight Generation
* Data-driven Recommendations

---

# Author

**Mohammad Varish**

Data Analyst | Python · SQL · Excel · Power BI



 **LinkedIn:** [https://www.linkedin.com/in/mohammad-varish1/]

 **GitHub:** [github.com/mvaris54](https://github.com/mvaris54)

