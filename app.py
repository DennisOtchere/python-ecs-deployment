from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Application Running"

@app.route("/<name>")
def welcome(name):
    return f"Welcome {name.title()}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=3000)