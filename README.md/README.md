# Olist E-commerce Customer & Operations Intelligence

An end-to-end e-commerce analytics project focused on customer experience, delivery performance, customer feedback and business insights.

## Project Overview

This project uses the Olist Brazilian E-Commerce Public Dataset to explore how customer experience and operational performance can be understood through data.

The analysis combines SQL, Python, sentiment analysis and Power BI to examine customer reviews, delivery performance, complaint patterns and product revenue.

The goal is to move beyond basic sales reporting and identify patterns that can support better business and operational decisions.

## Business Questions

- What does customer feedback reveal about the overall shopping experience?
- What is the distribution of positive, neutral and negative customer sentiment?
- How does customer feedback differ between late and on-time deliveries?
- Which complaint themes appear most frequently?
- What patterns can be identified in customer experience over time?
- What insights can be presented to business stakeholders?

## Tools and Technologies

- **SQL / PostgreSQL:** Data querying and analysis.
- **Python:** Data preparation, analysis and text processing.
- **Sentiment Analysis:** Pretrained multilingual XLM-RoBERTa model from Cardiff NLP.
- **Power BI:** Interactive dashboards, KPIs and business reporting.
- **Jupyter Notebook / Google Colab:** Analysis and documentation of the workflow.
- **GitHub:** Project version control and presentation.

## Project Structure

```text
olist-ecommerce-intelligence/
│
├── README.md
├── data/
│   ├── raw/
│   └── processed/
│
├── notebooks/
│   ├── Olist_Ecommerce_Analytics.ipynb
│   └── Olist_AI_Customer_Review_Intelligence.ipynb
│
├── sql/
│   └── olist_analysis.sql
│
├── powerbi/
│   └── Olist_Ecommerce_Intelligence.pbix
│
├── docs/
│   ├── business_requirements.md
│   ├── data_dictionary.md
│   └── kpi_dictionary.md
│
└── visualizations/
```

## Key Analysis Areas

### 1. Customer Experience
Analysis of customer ratings and written reviews to understand overall satisfaction and sentiment patterns.

### 2. AI-Based Sentiment Analysis
Written customer comments are classified into Positive, Neutral and Negative sentiment using a pretrained multilingual sentiment analysis model.

### 3. Delivery Intelligence
Comparison of delivery performance and customer feedback to identify differences between late and early or on-time deliveries.

### 4. Complaint Analysis
Exploratory keyword-based classification of customer comments to identify recurring complaint themes.

### 5. Business Reporting
Power BI dashboards bring the analysis together through KPI cards, charts, comparisons and business recommendations.

## Selected Findings

- The sentiment analysis dataset contains 40,950 written customer reviews.
- The model classified 21,312 reviews as positive, 10,251 as negative and 9,387 as neutral.
- The average review score was approximately 3.67 out of 5.
- In the written-review delivery analysis, late deliveries had a higher negative sentiment rate than early or on-time deliveries.
- Delivery-related complaints were a prominent theme in the exploratory complaint analysis.

These findings describe the analysed data and should not be interpreted as proof of causation.

## Power BI Report

The report includes the following pages:

- Customer Experience Overview
- AI Insights
- Delivery Intelligence
- Complaint Analysis
- Executive Summary

## Repository Contents

- SQL analysis scripts
- Python notebooks
- Processed analytical datasets
- Power BI report
- Business requirements and metric documentation

## Notes

The original dataset is publicly available on Kaggle:

[Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

The original raw CSV files are not included in this repository. They can be downloaded directly from the source.Processed datasets and analytical outputs are included where appropriate. The project does not claim that sentiment model confidence represents model accuracy.

Complaint categorisation is exploratory and keyword-based, while sentiment classification uses a pretrained AI model.

Product revenue represents product sales value and should not be interpreted as profit.

## Author

Himanshi Wadhwa

Business Analytics | SQL | Python | Power BI | Data Analysis