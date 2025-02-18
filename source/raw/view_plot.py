import pandas as pd
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# Read the CSV file
df = pd.read_csv("absolute_positions.csv")

# Set figure size
fig = plt.figure(figsize=(12, 8))  # Adjust the size as needed
ax = fig.add_subplot(111, projection='3d')

# Function to plot data for all routes
def plot_all_routes(x_range=None, y_range=None, z_range=None, aspect_ratio=[1, 1, 1]):
    routes = df['Debug Name'].unique()
    for route in routes:
        route_data = df[df['Debug Name'] == route]
        ax.plot(route_data['Absolute X'], route_data['Absolute Y'], route_data['Absolute Z'], label=route)
    
    ax.set_xlabel('Absolute X Axis')
    ax.set_ylabel('Absolute Y Axis')
    ax.set_zlabel('Absolute Z Axis')
    
    # Set the specified scale for each axis
    if x_range:
        ax.set_xlim(x_range)
    if y_range:
        ax.set_ylim(y_range)
    if z_range:
        ax.set_zlim(z_range)

    # Set box aspect ratio
    ax.set_box_aspect(aspect_ratio)
    
    ax.legend()
    plt.show()

# Specify the ranges for each axis
x_range = [-3000, 1500]
y_range = [-3000, 3000]
z_range = [0, 200]
aspect_ratio = [4, 4, 1]  # Adjust the aspect ratio as needed (e.g., [3, 3, 1] for a rectangular prism)

# Plot all routes with specified ranges and aspect ratio
plot_all_routes(x_range, y_range, z_range, aspect_ratio)
