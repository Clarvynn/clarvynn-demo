from flask import Flask, jsonify, request
import random
# from otel_instrument import instrument_app
import time
import logging
import os

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

PORT = 5002

app = Flask(__name__)

@app.route('/name')
# @instrumented
def name():
    logger.debug(f"Received headers: {request.headers}")
    names = ["Alice", "Bob", "Charlie", "Dheeraj"]
    return jsonify({"name": random.choice(names)})

if __name__ == "__main__":
    # instrument_app(app)
    # app.run(port=5002)
    
    app.run(port=PORT)