# Clarvynn Demo - Flask Microservices with Exemplars

This demo showcases **Clarvynn's zero-code observability** with real Flask applications. See how Clarvynn instruments HTTP metrics and traces with exemplars - **zero code changes required**.

## Overview

- **Zero code changes** - Flask apps run normally with Clarvynn
- **Distributed tracing** - See requests flow across 3 microservices  
- **Exemplars in action** - Click rhombus points to jump from metrics to traces
- **Production-ready telemetry** - Industry-standard Prometheus + Grafana + Tempo

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                Flask Applications                       │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────┐ │
│  │   Server A      │ │   Server B      │ │   Server C  │ │
│  │   Port 6000     │ │   Port 5001     │ │   Port 5002 │ │
│  │   Main API      │ │   Greeting Svc  │ │   Name Svc  │ │
│  │ + Clarvynn      │ │ + Clarvynn      │ │ + Clarvynn  │ │
│  └─────────────────┘ └─────────────────┘ └─────────────┘ │
└─────────────────────────────────────────────────────────┘
                              │ OTLP Data
                              ▼
┌─────────────────────────────────────────────────────────┐
│                    LGTM Stack (Docker)                  │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐ │
│  │   Grafana   │ │ Prometheus  │ │  OpenTelemetry      │ │
│  │   :3000     │ │    :9090    │ │    Collector        │ │
│  └─────────────┘ └─────────────┘ └─────────────────────┘ │
│  ┌─────────────┐                                         │
│  │    Tempo    │                                         │
│  │    :3200    │                                         │
│  └─────────────┘                                         │
└─────────────────────────────────────────────────────────┘
```

## Quick Start Guide

### Prerequisites
- **Docker** (for LGTM observability stack)
- **Python 3.8+** (for Flask applications)
- **ARM Mac** (Clarvynn binary currently supports ARM Macs only)

---

### Step 1: Start the LGTM Observability Stack
```bash
./start-lgtm-stack.sh
```

This starts:
- **Grafana** at http://localhost:3000 (admin/admin)
- **Prometheus** at http://localhost:9090
- **Tempo** at http://localhost:3200  
- **OpenTelemetry Collector** at localhost:4317/4318

---

### Step 2: Set Up Python Environment
```bash
./setup-python-env.sh
```

This creates a virtual environment and installs Flask dependencies.

---

### Step 3: Install Clarvynn Binary

**For ARM Mac:**
```bash
# Install via Homebrew
brew tap clarvynn/tap
brew install clarvynn

# Verify installation
clarvynn --version
```

**Note:** Clarvynn currently supports ARM Macs only. Support for other platforms is coming soon.

---

### Step 4: Run Flask Applications with Clarvynn

**Important**: Use the provided `custom.yaml` configuration instead of running `clarvynn init`. The custom configuration is pre-tuned for this demo and matches the Grafana dashboard service names.

Open **3 separate terminals** and run:

#### Terminal 1 - Server A (Main API)
```bash
source clarvynn-demo-env/bin/activate
clarvynn run gunicorn clarvynn_examples.server_a:app -w 2 --threads 2 -b 127.0.0.1:6000 --config custom.yaml --profile server-a-prod
```

#### Terminal 2 - Server B (Greeting Service)  
```bash
source clarvynn-demo-env/bin/activate
clarvynn run uwsgi --ini clarvynn_examples/http_b.ini --workers 1 --threads 1 --config custom.yaml --profile server-b-prod
```

#### Terminal 3 - Server C (Name Service)
```bash
source clarvynn-demo-env/bin/activate
clarvynn run python clarvynn_examples/server_c.py --config custom.yaml --profile server-c-prod
```

---

### Step 5: Generate Traffic
```bash
./generate-traffic.sh
```

This generates requests to:
- **Server A**: `http://localhost:6000/` (calls other services)
- **Server B**: `http://localhost:5001/greet` (greeting service)
- **Server C**: `http://localhost:5002/name` (name service)

---

### Step 6: Verify Exemplars Are Working
```bash
./verify-exemplars.sh
```

This script checks:
- Prometheus accessibility
- Exemplar counts for each HTTP metric
- Distributed tracing correlation
- Sample trace IDs

---

### Step 7: View Exemplars in Grafana
1. Open http://localhost:3000 (admin/admin)
2. Go to **Dashboards** → **"Clarvynn Application Monitoring"**
3. Look for **rhombus-shaped points** on histogram charts
4. **Click rhombus points** to jump directly to traces in Tempo

**Note**: Grafana samples exemplars to avoid cluttering the dashboard. You'll see some rhombus points, but not all exemplars.

---

### Step 8: View All Exemplars in Prometheus (Optional)
1. Open http://localhost:9090
2. Query: `http_server_duration_milliseconds_bucket`
3. Go to **Graph** tab → Enable **"Show exemplars"**
4. See all exemplar points (not just sampled ones)

---

### Step 9: Stop the Demo
```bash
# Stop Flask applications (Ctrl+C in each terminal)
./stop-lgtm-stack.sh
```

## Understanding Exemplars

### What Are Exemplars?
Exemplars are **sample data points** that connect metrics to traces. When you see a slow request in your metrics, exemplars let you click directly to the exact trace that caused it.

### Why Grafana Shows Fewer Exemplars
Grafana **samples exemplars** to keep dashboards clean and performant. This is normal behavior - you'll see diamond points for representative samples, not every single request.

### Checking All Exemplars
Use `./verify-exemplars.sh` to see the total count of exemplars in Prometheus. This gives you confidence that exemplars are working even if Grafana only shows a subset.

## Demo Talking Points

### For Technical Teams
1. **"Zero code changes"** - Show the Flask code has no OpenTelemetry imports
2. **"Distributed tracing"** - One request flows through multiple services
3. **"Exemplars eliminate guesswork"** - Click rhombus → see exact trace
4. **"Production-ready metrics"** - Standard Prometheus format
5. **"Real-time observability"** - See metrics appear as you make requests

### For Business Teams
1. **"Faster troubleshooting"** - From hours to minutes
2. **"No development overhead"** - Zero code changes needed
3. **"Better user experience"** - Proactive issue detection
4. **"Reduced operational costs"** - Efficient problem resolution

## Troubleshooting

### No Exemplars Visible?
1. Make sure all 3 Flask services are running
2. Generate traffic: `./generate-traffic.sh`
3. Wait 30-60 seconds for metrics to appear
4. Check exemplar health: `./verify-exemplars.sh`

### Services Not Starting?
1. Check if ports 6000, 5001, 5002 are available
2. Ensure Python virtual environment is activated
3. Verify Clarvynn binary is in PATH

### LGTM Stack Issues?
1. Ensure Docker is running
2. Check if ports 3000, 9090, 3200, 4317, 4318 are available
3. Restart: `./stop-lgtm-stack.sh` then `./start-lgtm-stack.sh`

## Learn More

- **Clarvynn Website**: https://www.clarvynn.io
- **Documentation**: https://docs.clarvynn.io
- **GitHub**: https://github.com/clarvynn/clarvynn

---

**Experience zero-code observability with Clarvynn - no code changes required!** 