import os
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    hello = os.getenv("GREETINGS","Hello world")
    return hello

if __name__ == "__main__":
    app.run(debug=True)