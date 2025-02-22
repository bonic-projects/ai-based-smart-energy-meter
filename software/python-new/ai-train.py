import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LinearRegression
import joblib

# Load dataset
df = pd.read_csv("ai-cons-data.csv")

# Feature selection
X = df[["year", "month"]]
y = df["consumption"]

# Train-test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Feature scaling
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Train model
model = LinearRegression()
model.fit(X_train_scaled, y_train)

# Save the model and scaler
joblib.dump(model, "electricity_model.pkl")
joblib.dump(scaler, "scaler.pkl")

print("Model training complete. Model and scaler saved.")
