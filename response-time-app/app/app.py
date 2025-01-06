from flask import Flask, jsonify
from werkzeug.middleware.dispatcher import DispatcherMiddleware
from prometheus_client import make_wsgi_app

app = Flask(__name__)
processing_threads = []

app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {
    '/metrics': make_wsgi_app()
})

@app.route("/process", methods=["GET"])
def process_request_task():
    try:
        # Simulate CPU-intensive work
        for _ in range(10**7):  # Arbitrary computation to spike CPU
            pass
        return jsonify({"message": "Request processed successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/simulate-error", methods=["GET"])
def simulate_error():
    # Simulate a server-side error (manual 500)
    return jsonify({"error": "Forced server error"}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)