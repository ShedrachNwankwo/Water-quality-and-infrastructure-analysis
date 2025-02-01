# Water-quality-and-infrastructure-analysis
## This project focuses on analysing water quality and infrastructure

Water Quality and Infrastructure Analysis
This project focuses on analyzing water quality data, infrastructure improvements, and employee performance for water sources in various locations. The project uses SQL to join and filter data across multiple tables, identify problematic sources, and track project progress and Utilizing Power BI to Identify trends and patterns, Track key performance indicators (KPIs) and generate reports also create a public-facing dashboard for stakeholders to access critical information and make informed decisions.

## Project Overview
The analysis is centered on:

Evaluating water sources based on pollution results
Identifying infrastructure needs for various water source types
Tracking employee data to assess improvement efforts
Generating recommendations for improvement (e.g., installing filters, diagnosing infrastructure issues, etc.)
Database Structure

## The dataset contains several key tables, including:

- **visits**: Contains information on visits to each water source, including queue times and assigned employees.
- **well_pollution**: Tracks pollution results for well water sources.
- **water_source**: Stores metadata on each water source, including type and population served.
- **location**: Stores location-specific information, including town, province, and address.
- **Project_progress**: Tracks improvement projects for each source, including status and comments.

## Key Features

1. **Project Tracking**: Automatically updates improvement recommendations based on water quality results and queue times.
2. **Employee Performance**: Monitors employee performance by tracking discrepancies between auditor and surveyor assessments.
3. **Infrastructure Recommendations**: Generates specific infrastructure improvement actions based on data (e.g., installing additional taps for long queues).

## How to Run the Project

1. Import the SQL files provided in the /sql directory.
2. Populate the database with sample data, following the instructions in data_loading.sql.
3. Execute the query files to generate views, track progress, and analyze data.
4. The dataset is available in XLSX format. Due to compatibility limitations, it cannot be opened directly here. However, you can download the file and easily import it into Microsoft Excel or Google Sheets for viewing and analysis
5. Visual examples of the reports and dashboards can be found in the Power BI folder for your review.
6. The dataset was continuously updated throughout the project to ensure that reports reflected the most current information.

