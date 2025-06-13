from flask import Flask, jsonify, request, g
import requests
import os
# from otel_instrument import instrument_app
import time
import logging

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

app = Flask(__name__)

@app.route('/')
# @instrumented
def home():
    logger.debug("Handling / request")
    # headers = getattr(g, 'trace_headers', {})
    greeting_response = requests.get("http://localhost:5001/greet")
    name_response = requests.get("http://localhost:5002/name")
    greeting = greeting_response.json()["greeting"]
    name = name_response.json()["name"]
    return jsonify({"message": f"{greeting} {name}"})

@app.route('/other')
# @instrumented
def other():
    logger.debug("Handling /other request")
    return jsonify({"message": "Other endpoint"})

@app.route('/fail')
# @instrumented
def fail():
    logger.debug("Handling /fail request")
    raise ValueError("Oops!")

if __name__ == "__main__":
    # instrument_app(app)
    logger.info("Starting server-a")
    # app.run(host="0.0.0.0", port=6000)
    PORT = 6000
    app.run(host="0.0.0.0", port=PORT)