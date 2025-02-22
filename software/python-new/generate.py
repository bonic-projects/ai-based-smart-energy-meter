import csv
import datetime

def generate_electricity_data(start_year, start_month,end_year, end_month, annual_growth_rate):
    filename = "ai-cons-data.csv"
    headers = ["year", "month", "consumption"]
    
    # Seasonal impact factor for each month (arbitrary values to simulate real-world trends)
    seasonal_factors = {
        1: 0.9,  # Winter - Low
        2: 0.95,
        3: 1.0,
        4: 1.1,  # Spring - Moderate
        5: 1.15,
        6: 1.2,  # Summer - High
        7: 1.25,
        8: 1.3,
        9: 1.1,  # Fall - Moderate
        10: 1.0,
        11: 0.95,
        12: 0.9   # Winter - Low
    }
    
    # Initial base consumption
    base_consumption = 300  # Arbitrary starting value (can be adjusted)
    
    # Convert growth rate to monthly multiplier
    monthly_growth_rate = (1 + annual_growth_rate / 100) ** (1 / 12)
    
    # Open CSV file for writing
    with open(filename, "w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(headers)
        
        # Iterate through the months
        current_date = datetime.date(start_year, start_month, 1)
        end_date = datetime.date(end_year, end_month, 1)
        
        consumption = base_consumption
        
        while current_date <= end_date:
            year = current_date.year
            month = current_date.month
            
            # Apply seasonal and time-based growth
            adjusted_consumption = consumption * seasonal_factors[month]
            
            # Write data to CSV
            writer.writerow([year, month, round(adjusted_consumption, 2)])
            
            # Increment consumption with growth rate
            consumption *= monthly_growth_rate
            
            # Move to the next month
            if month == 12:
                current_date = datetime.date(year + 1, 1, 1)
            else:
                current_date = datetime.date(year, month + 1, 1)
    
    print(f"CSV file '{filename}' generated successfully!")

# Get user inputs
start_year = int(input("Enter start year: "))
start_month = int(input("Enter start month: "))
end_year = int(input("Enter end year: "))
end_month = int(input("Enter end month: "))
annual_growth_rate = float(input("Enter annual growth rate (percentage): "))

generate_electricity_data(start_year, start_month, end_year, end_month, annual_growth_rate)
