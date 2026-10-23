# Power BI Deliverable

Open Power BI Desktop after running `notebooks/ecommerce_analysis.ipynb` and load `data/power_bi_sales.csv`. This dataset includes the cleaned transaction fields plus `CustomerType` and `Segment` calculated by Python.

Recommended one-page layout:

- KPI cards: Total Revenue, Total Orders, Total Customers, Average Order Value
- Line chart: `YearMonth` by `Revenue`
- Bar chart: top products by `Revenue`
- Bar or map: `Country` by `Revenue`
- Customer segment chart: Customer count by `Segment`
- Slicers: `Year`, `Month`, and `Country`

The `.pbix` file is a Power BI Desktop binary and cannot be generated reliably outside Power BI Desktop. Save the finished report here as `dashboard/ecommerce_dashboard.pbix`.
