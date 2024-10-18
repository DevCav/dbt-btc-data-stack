# Modern Data Tech Stack with Docker

This project demonstrates how to build a local data tech stack using Docker. The stack includes PostgreSQL for databases, Airflow for orchestrating workflows, dbt for data transformations, and Superset for data visualization. Each component is containerized for ease of setup and management.

## Prerequisites

- Docker
- Docker Compose
- Raw data should be loaded into the `/data/` directory with the name `btcusdt.csv`

## Getting Started

### Environment Variables

Create a `.env` file in the project root to set up the required environment variables:

```
POSTGRES_USER=your_postgres_user
POSTGRES_PASSWORD=your_postgres_password
SUPERSET_ADMIN=your_superset_admin
SUPERSET_PASSWORD=your_superset_password
SUPERSET_SECRET_KEY=your_superset_secret_key
```

# Project Structure
```
├── README.MD
├── airflow
│   ├── Dockerfile
│   ├── airflow.cfg
│   ├── dags
│   ├── entrypoint.sh
│   ├── requirements.txt
│   ├── scripts
│   └── webserver_config.py
├── data
│   ├── crm_sales_data
├── dbt
│   ├── analyses
│   ├── dbt_packages
│   ├── dbt_project.yml
│   ├── macros
│   ├── models
│   ├── packages.yml
│   ├── profiles.yml
│   ├── requirements.txt
│   ├── seeds
│   ├── snapshots
│   ├── target
│   └── tests
├── docker-compose.yml
├── postgres_datawarehouse
│   └── postgresql.conf
└── superset
    ├── Dockerfile
    ├── init_superset.sh
    └── superset_config.py
```
### Setting Up Services

1. **Build and Start Services**

   ```bash
   docker-compose up --build

2. Access Services
	•	Airflow: http://localhost:8080
	•	Superset: http://localhost:8088

### Services Overview
#### PostgreSQL:
### Services Overview

- **PostgreSQL**:
  - **Airflow DB**: Used by Airflow for metadata.
  - **Company DW**: Data warehouse for storing and processing data.
  - **Superset DB**: Used by Superset for metadata and storing dashboard data.
  - **Exposed Ports**:
    - Airflow DB: `5433`
    - Company DW: `5435`
    - Superset DB: `5434`

- **Airflow**:
  - Orchestrates workflows.
  - Contains several services: `airflow-scheduler`, `airflow-webserver`, `airflow-worker`, `airflow-init`.
  - Airflow webserver is accessible at port `8080`.
  - **Resources**:
    - [Airflow Documentation](https://airflow.apache.org/docs/)

- **Redis**:
  - Message broker for Airflow's CeleryExecutor.
  - **Exposed Port**: `6379`
  - **Resources**:
    - [Redis Documentation](https://redis.io/documentation)

- **dbt**:
  - Transforms data in the data warehouse.
  - Run dbt commands within the `dbt-serve` service.
  - **Resources**:
    - [dbt Documentation](https://docs.getdbt.com/docs/introduction)

- **Superset**:
  - Visualizes data stored in the data warehouse.
  - Connects to the `superset_db` PostgreSQL instance.
  - Superset is accessible at port `8088`.
  - **Resources**:
    - [Superset Documentation](https://superset.apache.org/docs/)

### Data Ingestion and Transformation

- **Data**: Located in the `data` folder.
  - `btcusdt.csv`

- **Airflow Service**: Ingests the sample data and runs dbt models located in the `dbt` folder.
- **DBT Models**: Transform the ingested data in the data warehouse.

### Conclusion & DAG
![alt text](https://file%2B.vscode-resource.vscode-cdn.net/Users/devincavagnaro/Documents/dev/dbt-btc-data-stack/Images/dbt%20DAG.png?version%3D1729108343117)
By following these steps, you can set up a robust data tech stack locally using Docker. This setup includes PostgreSQL for databases, Airflow for workflow orchestration, dbt for data transformation, and Superset for data visualization. Each service is containerized for easy management and deployment. Use the provided links to explore more about each service and enhance your data stack further.

##

## Answering questions in Take Home
## 1. Which hour of the day had the biggest returns?
```sql
    with cumulative_returns as (
        select
            open_hour,
            exp(sum(ln(1 + percent_gain))) - 1 as total_return
        from
            fct_hourly_trades
        group by
            open_hour
    )
    select
        open_hour,
        total_return
    from
        cumulative_returns
    order by
        total_return desc
```

#### Understanding `EXP(SUM(LN(1 + percent_gain))) - 1`

The expression `EXP(SUM(LN(1 + percent_gain))) - 1` is used to calculate the cumulative return when reinvesting profits/losses at each step. Here is how it works:

### Goal
Goal is to calculate the overall cumulative return for an investment strategy that reinvests all returns continuously every hour. Since returns are compounded across multiple periods, multiply the returns for each period. For instance, if you invest 1 unit of bitcoin and it gains 10% in the first hour, and then gains 5% in the next hour, you would end up with:

- After 1st hour: `1.0 * (1 + 0.10) = 1.10`
- After 2nd hour: `1.10 * (1 + 0.05) = 1.155`

Instead of repeatedly multiplying, we use logarithms to make the math easier to handle, especially for longer series of periods.

### Why Use Logarithms?
When you have multiple returns that are reinvested over time, you typically multiply the individual return factors together. However, multiplying many numbers can be computationally difficult and less intuitive when working with SQL. Instead, you can:

1. Take the logarithm of each return factor to transform the multiplication into addition.
2. Sum the logarithms.
3. Convert back to the original value by using the exponential function.

### Breaking Down the Expression
1. **`LN(1 + percent_gain)`**:
   - `percent_gain` represents the return for each hour (e.g., 0.10 for a 10% gain).
   - Adding `1` to `percent_gain` gives you the factor by which the value grows (e.g., `1 + 0.10 = 1.10`).
   - Taking the natural logarithm (`LN`) of this factor allows you to convert the multiplication of return factors into addition.

2. **`SUM(LN(1 + percent_gain))`**:
   - Summing up the logarithms of each hourly return factor accumulates the returns in a way that is equivalent to multiplying them.

3. **`EXP(SUM(LN(1 + percent_gain)))`**:
   - After summing the logarithms, you use the exponential function (`EXP`) to convert the sum back to the original scale.
   - This gives you the cumulative growth factor.

4. **`EXP(SUM(LN(1 + percent_gain))) - 1`**:
   - The `- 1` at the end is to convert the growth factor back to the cumulative percentage gain.
   - For example, if the growth factor is `1.155`, subtracting `1` gives `0.155`, which is a cumulative return of 15.5%.

### Example
If the data for a given hour looks like this:

| open_date  | open_hour | percent_gain |
|------------|-----------|--------------|
| 2024-10-10 | 15        | 0.10         |
| 2024-10-11 | 15        | 0.05         |
| 2024-10-12 | 15        | -0.02        |

The steps are:
1. Calculate the growth factors: 
   - `1 + 0.10 = 1.10`
   - `1 + 0.05 = 1.05`
   - `1 - 0.02 = 0.98`
2. Take the logarithm of each:
   - `LN(1.10)`, `LN(1.05)`, `LN(0.98)`
3. Sum the logarithms:
   - `LN(1.10) + LN(1.05) + LN(0.98)`
4. Take the exponential of the sum to get the cumulative growth factor:
   - `EXP(LN(1.10) + LN(1.05) + LN(0.98))`
5. Subtract 1 to get the cumulative return:
   - `EXP(LN(1.10) + LN(1.05) + LN(0.98)) - 1`

This process ensures you get the correct cumulative return for reinvested profits or losses over multiple periods.


## 2. Which hour of the day had the lowest maximum losses?

To determine which hour of the day had the lowest maximum losses, you need to identify the hour that experienced the least severe worst-case performance over time. Below is the SQL query that answers this question:

```sql
  with hourly_losses as (
      select
          open_hour,
          min(percent_gain) as max_loss
      from
          fct_hourly_trades
      group by
          open_hour
  ),
  lowest_max_loss as (
      select
          open_hour,
          max_loss
      from
          hourly_losses
      order by
          max_loss desc
      limit 1
  )
  select
      open_hour,
      max_loss
  from
      lowest_max_loss;
```

### Explanation
1. **`WITH hourly_losses AS`**:
   - This Common Table Expression (CTE) calculates the **minimum value of `percent_gain`** (i.e., the largest loss) for each `open_hour`.
   - `MIN(percent_gain)` gives the worst (most negative) performance for each hour over the dataset.

2. **`lowest_max_loss AS`**:
   - From the `hourly_losses` CTE, this part selects the hour with the **least severe maximum loss**. In other words, it finds the hour with the **smallest negative return**.
   - Sorting by `max_loss DESC` helps to get the "least negative" value at the top, and `LIMIT 1` selects that hour.

3. **`SELECT open_hour, max_loss`**:
   - Finally, the query returns the hour (`open_hour`) and its corresponding `max_loss` value, which represents the hour with the lowest maximum losses.

The lowest maximum loss refers to the hour of the day where the worst-case negative return (i.e., the biggest loss) was the least severe compared to other hours. In other words, it is the hour during which the losses were not as bad as the worst losses experienced in other hours.


### Adjusting for various dates

If an analyst wants to view metrics like cumulative returns or the lowest maximum loss starting from a specific date, they can adjust their query to filter for records where the date is greater than or equal to the desired open_date. Alternatively, to make this more user-friendly, a dropdown could be added to the dashboard. This would allow analysts to select the open_date directly, automatically adjusting the metrics displayed.


### Sample Dashboard in Superset

![alt text](Images/Sample%20Superset%20Dashboard.png?version%3D1729287740088)