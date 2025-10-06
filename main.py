import os
import requests
from datetime import datetime

token = os.getenv("GITHUB_TOKEN")
repo = os.getenv("GITHUB_REPOSITORY")

headers = {"Authorization": f"token {token}"}
base_url = f"https://api.github.com/repos/{repo}/traffic"

def get_traffic(endpoint):
    r = requests.get(f"{base_url}/{endpoint}", headers=headers)
    r.raise_for_status()
    return r.json()

views = get_traffic("views")
clones = get_traffic("clones")

today = datetime.utcnow().strftime("%Y-%m-%d")
line = f"{today},{views['count']},{views['uniques']},{clones['count']},{clones['uniques']}\n"

csv_file = "traffic_log.csv"

if not os.path.exists(csv_file):
    with open(csv_file, "w") as f:
        f.write("date,views,unique_views,clones,unique_clones\n")

with open(csv_file, "a") as f:
    f.write(line)
