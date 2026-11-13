# KPI Dictionary

## Olist E-commerce Customer & Operations Intelligence

This document defines the key performance indicators used in the project. It explains what each metric measures and how it is calculated, so that the results can be interpreted consistently across the analysis and Power BI report.

### Customer Experience

**Total Written Reviews**

The total number of customer reviews containing written comments that were included in the sentiment analysis.

Calculation: Count of distinct review IDs in the AI sentiment results.

**Positive Reviews**

The number of written reviews classified as positive by the sentiment analysis model.

Calculation: Count of distinct review IDs where the predicted sentiment is Positive.

**Negative Reviews**

The number of written reviews classified as negative by the sentiment analysis model.

Calculation: Count of distinct review IDs where the predicted sentiment is Negative.

**Neutral Reviews**

The number of written reviews classified as neutral by the sentiment analysis model.

Calculation: Count of distinct review IDs where the predicted sentiment is Neutral.

**Average Review Rating**

The average customer rating given to the orders, based on the review score.

Calculation: Sum of review scores divided by the number of reviews with a valid rating.

### Delivery Performance

**Orders with Written Reviews**

The number of distinct orders represented in the delivery and review analysis.

Calculation: Count of distinct order IDs in the delivery review analysis dataset.

**Late Deliveries**

The number of reviewed orders delivered after the estimated delivery date.

Calculation: Count of distinct order IDs classified as Late.

**Average Delivery Days**

The average time taken to deliver an order, measured from the purchase date to the actual delivery date.

Calculation: Average of actual delivery days for orders with a recorded delivery date.

**Average Delay Days**

The average difference between the actual delivery date and the estimated delivery date.

Calculation: Average of delay days for delivered orders. A positive value indicates delivery after the estimated date.

**Negative Sentiment Rate**

The percentage of written reviews classified as negative.

Calculation: (Negative Reviews / Total Written Reviews) × 100.

**Negative Sentiment Rate by Delivery Performance**

The percentage of negative written reviews within each delivery performance group.

Calculation: (Negative Reviews in a delivery group / Total written reviews in that group) × 100.

### Complaint Analysis

**Unhappy Reviews**

The number of written reviews identified as unhappy for the complaint analysis.

**Complaint Theme Reviews**

The number of reviews associated with a particular complaint theme, such as delivery issues, customer service, or product quality.

The complaint themes were identified using keyword-based text classification. A review may be associated with more than one theme, so theme counts should not be added together and interpreted as a total number of unique reviews.

### Revenue Analysis

**Product Revenue**

The total value of products sold, calculated using the item price.

Calculation: Sum of product prices, excluding freight charges.

### Notes on Interpretation

- Sentiment labels were generated using a multilingual sentiment analysis model. They represent model predictions and should not be treated as manually verified customer opinions.
- Sentiment analysis was performed on reviews containing written comments, not on every review in the original dataset.
- Delivery comparisons show associations between delivery performance and customer feedback. They do not establish that delivery delays alone caused negative reviews.
- Complaint themes are exploratory keyword-based classifications. Some comments may be unclassified, and categories may overlap.
- Delivery metrics in the review analysis describe the orders included in that analysis and should not automatically be interpreted as metrics for every order in the original dataset.