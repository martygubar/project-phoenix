import jsonlines
import json

with open('/Users/mgubar/Code/project-phoenix/data-sets.json', 'r') as f:
    json_data = json.load(f)

with jsonlines.open('/Users/mgubar/Code/project-phoenix/data-sets-per-line.json', 'w') as writer:
    writer.write_all(json_data)
