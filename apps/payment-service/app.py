from flask import Flask, jsonify
import time
import random
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

@app.route('/health')
def health():
    """Health check endpoint"""
    logger.info("Health check requested")
    return jsonify({"status": "healthy"}), 200

@app.route('/api/users')
def get_users():
    """Fast successful endpoint (simulates DB query)"""
    logger.info("GET /api/users - Request received")
    logger.info("Querying user database")
    users = [
        {"id": 1, "name": "Alice"},
        {"id": 2, "name": "Bob"},
        {"id": 3, "name": "Charlie"}
    ]
    logger.info(f"Successfully fetched {len(users)} users")
    return jsonify(users), 200

@app.route('/api/slow')
def slow_endpoint():
    """Slow endpoint (simulates heavy processing)"""
    logger.info("GET /api/slow - Request received")
    logger.info("Starting heavy computation task")
    # Simulate slow operation (1-2 seconds)
    sleep_time = random.uniform(1.0, 2.0)
    logger.info(f"Processing will take approximately {sleep_time:.2f} seconds")
    time.sleep(sleep_time)
    logger.info("Heavy computation completed successfully")
    return jsonify({"message": "Slow operation completed"}), 200

@app.route('/api/error')
def error_endpoint():
    """Endpoint that returns 500 error"""
    logger.info("GET /api/error - Request received")
    logger.error("Simulating internal server error")
    logger.error("Stack trace would appear here in real scenario")
    logger.error("Error details: Database connection failed")
    return jsonify({"error": "Internal server error"}), 500

@app.route('/api/notfound')
def notfound():
    """Endpoint that returns 404"""
    logger.info("GET /api/notfound - Request received")
    logger.warning("Requested resource does not exist")
    logger.warning("Returning 404 to client")
    return jsonify({"error": "Not found"}), 404

@app.route('/api/payment')
def payment():
    """Critical business endpoint"""
    logger.info("POST /api/payment - Request received")
    logger.info("Validating payment details")
    logger.info("Initiating payment processing")
    
    # Always succeed for deterministic demo
    transaction_id = f"tx_{random.randint(10000, 99999)}"
    logger.info(f"Payment processed successfully - Transaction ID: {transaction_id}")
    return jsonify({"status": "success", "transaction_id": transaction_id}), 200

if __name__ == '__main__':
    # Disable Werkzeug access logs (development server noise)
    import logging as werkzeug_logging
    werkzeug_log = werkzeug_logging.getLogger('werkzeug')
    werkzeug_log.setLevel(werkzeug_logging.WARNING)
    
    logger.info("Starting Payment Service on port 8000")
    app.run(host='0.0.0.0', port=8000, debug=False)

