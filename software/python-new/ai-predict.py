import pandas as pd
import joblib
import bonic_cloud
import time
from datetime import datetime



def predict_consumption(year, month):
    # Load the trained model and scaler
    model = joblib.load("electricity_model.pkl")
    scaler = joblib.load("scaler.pkl")
    
    # Prepare input data
    input_data = pd.DataFrame([[year, month]], columns=["year", "month"])
    input_scaled = scaler.transform(input_data)
    
    # Make prediction
    prediction = model.predict(input_scaled)
    return round(prediction[0], 2)

def on_data_change(event):
    print('Data change event received')
    data = event.data
    if data:
        print('Event data:', data)
        
        timestamp = data.get("timestamp", "")
        if timestamp:
            try:
                dt = datetime.fromisoformat(timestamp)
                year = dt.year
                month = dt.month
                
                # Predict consumption
                predicted_consumption = predict_consumption(year, month)
                print(f"Predicted electricity consumption for {year}-{month}: {predicted_consumption}")
                
                # Update Firebase with the predicted value
                data_ref.update({
                    'result': predicted_consumption
                })
                print(f"Bonic cloud updated with predicted consumption: {predicted_consumption}")
            except Exception as e:
                print(f"Error processing timestamp: {e}")
        else:
            print("No valid timestamp found in event data")
    else:
        print("No data found in event")

# Initialize Bonic Cloud
bonic_cloud.init()
ref = bonic_cloud.get_ref_ai()
data_ref = bonic_cloud.get_data_ref_ai()

# Set up listener
try:
    ref.listen(on_data_change)
    print('Listening for data changes...')
except Exception as e:
    print(f"Error setting up listener: {e}")

# Keep the script running
while True:
    time.sleep(1)
