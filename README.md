# Hotel-Booking-Analytics---Cancellation-Prediction-Project

This project analyzes 119k+ hotel booking records to uncover insights related to customer behavior, seasonality, pricing patterns, and cancellation dynamics.
The workflow includes:

- SQL-based data cleaning & preprocessing
- Feature engineering (dates, stay length, lead time, guest segmentation)
- KPI modeling
- Power BI dashboard development
- Analytical storytelling via PDF report & PPT presentation

# Project Objectives

- Clean and prepare raw hotel booking data using SQL

- Analyze booking trends, cancellations, guest behavior & revenue drivers

- Build KPIs to evaluate hotel performance

- Develop a fully interactive Power BI dashboard

- Present insights and strategic recommendations for stakeholders

# Tools & Technologies Used

<table>
  <tr>
    <th>Category</th>
    <th>Tools</th>
  </tr>
  <tr>
    <td>Data Cleaning</td>
    <td>MySQL (advanced SQL cleaning, joins, type conversion)</td>
  </tr>
  <tr>
    <td>Analytics	</td>
    <td>SQL KPIs, Descriptive Statistics</td>
  </tr>
  <tr>
    <td>Visualization</td>
    <td>Power BI (DAX, data modeling, dashboarding)</td>
  </tr>
  <tr>
    <td>Documentation</td>
    <td>PowerPoint, PDF Report, Markdown</td>
  </tr>
  <tr>
    <td>Data Processing</td>
    <td>Excel (dataset inspection)</td>
  </tr>
</table>

# Dataset Details

- Dataset includes key booking attributes such as:

- Customer demographics (adults, children, babies)

- Dates (arrival date, booking date, reservation status date)

- Stay details (weekend & week nights)

- Pricing (ADR – average daily rate)

- Lead time & special requests

- Booking source (agent/company/direct)

- Market segment & distribution channel

- Cancellation & reservation status

<h3><b>Dataset File:</b></h3>

hotel_booking_cleaned.csv

<h3><b>Lookup tables:</b></h3>

market_segment_lookup

distribution_channel_lookup

country_continent_lookup

# SQL Cleaning & Transformation Workflow

- The SQL file includes:

- Null handling & fixing inconsistent values

- Adding booking source, flags & enriched attributes

- Deriving features:

  <pre>arrival_date

  reservation_status_dt

  stay_length

  guest_count

  booking_date

  season classification

  Detecting anomalies</pre>

- KPI calculations (Booking Volume, Revenue, Cancellations, Lead Time etc.)

 SQL File:
- **SQL Script:** [hotel_project_final.sql](./SQL/hotel_project_final.sql)


# Power BI Dashboard

Dashboard contains:

<h3><b>1. Booking Performance Overview</b></h3>

- Total bookings, cancellations, returning users

- Seasonal & monthly booking trends

- Lead time distribution

- ADR patterns (overall, by hotel, by month)

<h3><b>2️. Revenue Analysis</b></h3>

- Realized vs unrealized revenue

- Revenue by year, season, hotel type

<h3><b>3. Customer Behavior</b></h3>

- Guest count segmentation

- LOS (length of stay)

- Bookings with special requests

<h3><b>4️. Cancellation Intelligence</b></h3>

- Cancellation trends by year

- Cancellation rate by lead-time bucket

- Market segment & country-level cancellation heatmaps

<b>Power BI Dashboard File:</b>
- **Power BI Dashboard:** [hotel_booking_final.pbix](./PowerBI_Dashboard/hotel_booking_final.pbix)


# Reports & Presentation
<b>Final Report (PDF)</b>

Includes complete analysis summary, KPIs, and insights.
- **Final Report (PDF):** [Dhruv_CapstoneProjectReport.pdf](./Reports/Dhruv_CapstoneProjectReport.pdf)


<b>PowerPoint Presentation</b>

Story-driven explanation of objectives, data cleaning, KPIs, insights & recommendations.
- **Presentation (PPTX):** [Data Collection and Analysis_final.pptx](./Reports/Data%20Collection%20and%20Analysis_final.pptx)

# Key Insights (Summary)
<h3><b>Booking Performance</b></h3>

- City Hotel receives higher bookings but also higher cancellations

- High seasonality observed — summer peak

- Lead time strongly impacts cancellation rate

<h3><b>Revenue Insights</b></h3>

- Highest revenue generated in peak holiday months

- Resort Hotel yields higher ADR than City Hotel

<h3><b>Guest Behavior</b></h3>

- Majority of bookings made for 2-person stays

- Families prefer Resort Hotel

- Higher stay length = higher realized revenue

<h3><b>Cancellation Findings</b></h3>

- Long lead-time bookings show the highest cancellations

- Some markets & countries show disproportionately high cancellation rates

- Potential lost revenue is significant → key opportunity area

#  Strategic Recommendations

- Optimization Opportunities

- Improve cancellation policy for long lead time segments

- Enhance pricing strategy for high-demand seasons

- Promote off-season packages

- Personalize marketing for repeat guests

- Optimize waiting list & ADR variance

- Customer Experience

- Provide better offers for family travelers

- Introduce loyalty program for reducing cancellations

# Project Structure
Hotel-Booking-Analytics-&-Cancellation-Prediction-Project/<br>
│<br>
├── Dataset/Hotel_booking_Datasets.zip/<br>
│   ├── hotel_booking_cleaned.csv<br>
│   ├── lookup_market_segment.csv<br>
│   ├── lookup_distribution_channel.csv<br>
│   └── lookup_country_continent.csv<br>
│<br>
├── SQL/<br>
│   └── hotel_project_final.sql<br>
│<br>
├── PowerBI_Dashboard/<br>
│   └── hotel_booking_final.pbix<br>
│<br>
├── Reports/<br>
│   ├── Dhruv_CapstoneProjectReport.pdf<br>
│   └── Data Collection and Analysis_final.pptx<br>
│<br>
└── README.md<br>

# Outcome

This project delivers:

- A fully cleaned & analysis-ready booking dataset
- SQL scripts covering advanced cleaning + feature engineering
- A complete Power BI dashboard for analytical insights
- A polished business-ready report & presentation
- A strong portfolio project for Data Analyst / BI roles
