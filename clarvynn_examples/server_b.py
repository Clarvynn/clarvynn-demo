from flask import Flask, jsonify, request
import random
# from otel_instrument import instrument_app
import time
import logging
import os

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

PORT = 5001

app = Flask(__name__)

@app.route('/greet')
# @instrumented
def greet():
    logger.debug(f"Received headers: {request.headers}")
    greetings = ["Hi", "Hello"]
    return jsonify({"greeting": random.choice(greetings)})

if __name__ == "__main__":
    # instrument_app(app)
    # app.run(port=5001)
    
    app.run(port=PORT)