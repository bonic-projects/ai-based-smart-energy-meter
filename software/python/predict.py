import torch
import torch.nn as nn
import bonic_cloud
import time

# Step 1: Define the model architecture
class UpdatedEnergyPredictor(nn.Module):
    def __init__(self):
        super(UpdatedEnergyPredictor, self).__init__()
        self.layer1 = nn.Linear(4, 64)  # Input layer (4 features) -> Hidden layer (64 neurons)
        self.layer2 = nn.Linear(64, 32) # Hidden layer (64 neurons) -> Hidden layer (32 neurons)
        self.layer3 = nn.Linear(32, 1)  # Hidden layer (32 neurons) -> Output layer (1 value)

    def forward(self, x):
        x = torch.relu(self.layer1(x))  # Activation function for hidden layers
        x = torch.relu(self.layer2(x))
        x = self.layer3(x)              # No activation for output layer
        return x

# Step 2: Initialize the model and load the saved state dictionary
model = UpdatedEnergyPredictor()
try:
    model.load_state_dict(torch.load('updated_energy_predictor_model.pth'))
    model.eval()  # Set model to evaluation mode
    print("Model loaded successfully")
except Exception as e:
    print(f"Error loading model: {e}")

# Step 3: Prediction function
def predict_energy(year, month, avg_adult, avg_kid):
    try:
        inputs = torch.tensor([[year, month, avg_adult, avg_kid]], dtype=torch.float32)
        with torch.no_grad():  # Disable gradient calculations for prediction
            predicted_kwh = model(inputs)
        return round(predicted_kwh.item(), 2)
    except Exception as e:
        print(f"Error during prediction: {e}")
        return None

# Step 4: Helper function to convert month names to numerical values
def month_to_number(month_name):
    months = {
        "January": 1, "February": 2, "March": 3, "April": 4,
        "May": 5, "June": 6, "July": 7, "August": 8,
        "September": 9, "October": 10, "November": 11, "December": 12
    }
    return months.get(month_name, -1)

# Step 5: Event listener callback function
def on_data_change(event):
    print('Data change event received')
    data = event.data
    if data:
        print('Event data:', data)

        # Extract and validate data from Firebase
        year = data.get('year', 'N/A')
        month = data.get('month', 'N/A')
        avg_adult = data.get('adults', 'N/A')
        avg_kid = data.get('kids', 'N/A')

        if all(val != 'N/A' for val in [year, month, avg_adult, avg_kid]):
            try:
                year = float(year)
                month = float(month_to_number(month))
                avg_adult = float(avg_adult)
                avg_kid = float(avg_kid)

                # Predict energy usage
                predicted_kwh = predict_energy(year, month, avg_adult, avg_kid)
                print(f"Predicted kWh: {predicted_kwh}")

                if predicted_kwh is not None:
                    # Update Firebase with the predicted value
                    data_ref.update({
                        'result': predicted_kwh
                    })
                    print(f"Bonic cloud updated with predicted kWh: {predicted_kwh}")
                else:
                    print("Prediction failed")  #failed
            except Exception as e:
                print(f"Error processing data: {e}")
        else:
            print("Invalid data received")
    else:
        print("No data found in event")

# Step 6: Bonic cloud initialization
bonic_cloud.init()
ref = bonic_cloud.get_ref()
data_ref = bonic_cloud.get_data_ref()

# Step 7: Set up Bonic cloud listener
try:
    ref.listen(on_data_change)
    print('Listening for data changes...')
except Exception as e:
    print(f"Error setting up listener: {e}")

# Keep the script running to listen for data changes
while True:
    time.sleep(1)
