from flask import Flask
import subprocess
import os

app = Flask(__name__)

# Define the paths to your files along with the corresponding installation ids
star_files = [
    {
        "file": "sample1.star", 
        "installation_id": "Sample1",
    },
    {
        "file": "sample2.star", 
        "installation_id": "Sample2",
    },
    # Add more files as needed
]

# Define your Tidbyt device IDs and API tokens along with a list of excluded star files
devices = [
    {
        "id": "your_device_id1",
        "api_token": "your_token",
        "exclusions": [],
    },
    {
        "id": "your_device_id2",
        "api_token": "your_token",
        "exclusions": [],
    },
    # Add more devices as needed
]

@app.route("/")
def publish_tidbyt():
    # Command to check pixlet version
    results = []

    for star in star_files:
        # Render the app
        webp_file_path = star["file"].replace(".star", ".webp")
        render_command = f"pixlet render {star['file']} -o {webp_file_path}"

        # Check if the star file exists
        if os.path.exists(star['file']):
            # File exists, so proceed with the render command
            try:
                process = subprocess.run(render_command, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

                # If the command succeeds, pixlet is installed
                for device in devices:
                    # Skip if the star file is in the list of exclusions for the device
                    if star['file'] in device['exclusions']:
                        continue

                    # Publish the app
                    publish_command = f"pixlet push --api-token {device['api_token']} --installation-id {star['installation_id']} {device['id']} {webp_file_path}"
                    subprocess.run(publish_command, shell=True, check=True)
                results.append(f"Updated Tidbyt display successfully {star['installation_id']}")    
                
            except subprocess.CalledProcessError as e:
                # If the command fails, pixlet is not installed
                output = e.output.decode()
                stderr = e.stderr.decode()
                return f"File is there, but render doesn't work. Output: {output} Error: {stderr}"
        else:
            # File does not exist
            return f"The file '{star['file']}' does not exist."
    result_string = "\n".join(results)
    return result_string, 200
    
if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
