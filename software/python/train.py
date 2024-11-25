import pandas as pd
import torch
import torch.nn as nn
import torch.optim as optim
from sklearn.model_selection import train_test_split

# Load the dataset
data = pd.read_csv('energy_consumption_data_with_year.csv')

# Step 1: Prepare the dataset
# Extract features (year, month, avg_adult, avg_kid) and target (kwh)
X = data[['year', 'month', 'avg_adult', 'avg_kid']].values  # Features: year, month, avg_adult, avg_kid
y = data['kwh'].values  # Target: kwh

# Split the data into training and testing sets (80% train, 20% test)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Step 2: Define a simple neural network model
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

# Initialize the model, loss function, and optimizer
model = UpdatedEnergyPredictor()
criterion = nn.MSELoss()  # Mean Squared Error for regression tasks
optimizer = optim.Adam(model.parameters(), lr=0.001)

# Step 3: Train the model
# Convert training data to PyTorch tensors
X_train_tensor = torch.tensor(X_train, dtype=torch.float32)
y_train_tensor = torch.tensor(y_train, dtype=torch.float32).view(-1, 1)

# Number of epochs
num_epochs = 500

for epoch in range(num_epochs):
    # Forward pass: Compute predicted kWh by passing inputs to the model
    outputs = model(X_train_tensor)
    loss = criterion(outputs, y_train_tensor)

    # Backward pass and optimization
    optimizer.zero_grad()  # Clear the gradients
    loss.backward()        # Backpropagate the error
    optimizer.step()       # Update weights

    # Print the loss every 50 epochs for tracking progress
    if (epoch + 1) % 50 == 0:
        print(f'Epoch [{epoch + 1}/{num_epochs}], Loss: {loss.item():.4f}')

# Step 4: Test the model (optional)
model.eval()  # Set the model to evaluation mode
X_test_tensor = torch.tensor(X_test, dtype=torch.float32)
y_test_tensor = torch.tensor(y_test, dtype=torch.float32).view(-1, 1)

with torch.no_grad():
    predictions = model(X_test_tensor)
    test_loss = criterion(predictions, y_test_tensor)
    print(f'Test Loss: {test_loss.item():.4f}')

# After training, save the model
torch.save(model.state_dict(), 'updated_energy_predictor_model.pth')

# Step 5: Make predictions (using test input)
def predict_energy(year, month, avg_adult, avg_kid):
    # Prepare input for prediction
    inputs = torch.tensor([[year, month, avg_adult, avg_kid]], dtype=torch.float32)
    with torch.no_grad():
        predicted_kwh = model(inputs)
    return predicted_kwh.item()

# Example prediction
example_year = 2023
example_month = 6
example_avg_adult = 4
example_avg_kid = 2
predicted_kwh = predict_energy(example_year, example_month, example_avg_adult, example_avg_kid)
print(f'Predicted kWh for year {example_year}, month {example_month}, {example_avg_adult} adults, and {example_avg_kid} kids: {predicted_kwh:.2f}')
