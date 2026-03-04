import os
import subprocess

# Function to add metadata to a video file using FFmpeg
def add_metadata(input_file, output_file, metadata):
    # Build the FFmpeg command to add metadata
    cmd = ['ffmpeg', '-i', input_file]
    
    # Add metadata fields to the command
    for key, value in metadata.items():
        cmd.extend(['-metadata', f'{key}={value}'])
    
    # Copy the video and audio streams without re-encoding
    cmd.extend(['-c:v', 'copy', '-c:a', 'copy', output_file])

    # Execute the FFmpeg command
    try:
        subprocess.run(cmd, check=True)
        print(f"Metadata added successfully to {output_file}")
    except subprocess.CalledProcessError as e:
        print(f"Error adding metadata to {input_file}: {e}")

# Function to process all video files in a folder
def process_folder(folder_path, metadata, output_folder=None):
    # Check if the folder exists
    if not os.path.exists(folder_path):
        print(f"The folder {folder_path} does not exist.")
        return
    
    # Create output folder if it doesn't exist and output_folder is provided
    if output_folder and not os.path.exists(output_folder):
        os.makedirs(output_folder)
    
    # List all video files in the folder
    for filename in os.listdir(folder_path):
        file_path = os.path.join(folder_path, filename)
        
        # Only process video files (check extension)
        if os.path.isfile(file_path) and filename.lower().endswith(('.mp4', '.mov', '.avi', '.mkv')):
            # Define output file path
            if output_folder:
                output_file = os.path.join(output_folder, filename)
            else:
                output_file = file_path  # Overwrite the file in the same folder

            # Call the function to add metadata to each file
            add_metadata(file_path, output_file, metadata)

# Example metadata to be added to the video
metadata = {
    "title": "Euro Truck Simulator 2 DAF XG+ 450HP 12 speeds 2025-11-07 11-52-49",
    "contributing_artist": "DriveHost24 Gamer (Driver, Host)",
    "director": "DriveHost24 Gamer",
    "producers": "DriveHost24 Media Team",
    "writers": "DriveHost24 Gamer Gameplay Edit",
    "year": "2025",
    "genre": "Simulation, Driving, Realism, Trucking Gameplay",
    "publisher": "DriveHost24 Studios",
    "content_provider": "DriveHost24 – The Ultimate Truck Simulation Channel",
    "encoded_by": "DriveHost24 Video Production (FFMPEG / DaVinci Resolve/ Shortcut / HandBrake)",
    "author": "DriveHost24 / BlueHost Gamer",
    "copyright": "© 2025 DriveHost24. All rights reserved.Reproduction, redistribution, or modification of this video without permission is strictly prohibited.",
    "comment": "For more information, visit: https://www.youtube.com/@DriveHost24"
}

# Folder containing the video clips
input_folder = 'ETS2_4K_VERTICAL_444_10bit_NVENC_1G'

# Optional: specify an output folder (or leave as None to overwrite)
output_folder = 'ReEncodeMetaData'  # You can set this to None to overwrite

# Process the videos in the folder
process_folder(input_folder, metadata, output_folder)
