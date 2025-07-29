from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/plantinfo', methods=['POST'])
def get_plant_info():
    data = request.get.json()
    plant_name = data.get('plant')

# mock data for now
    return jsonify({
        "plant": plant_name,
        "sun": "Full sun",
        "water": "1 inch per week",
        "soil": "Well-drained, fertile",
        "harvest": "When ripe and red",
        "extra_care": "Stake the plant and prune suckers"
    })

if __name__ == '__main__':
    app.run(debug=True)