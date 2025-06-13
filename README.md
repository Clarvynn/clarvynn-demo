# 🚀 Clarvynn Demo - Flask Microservices with Exemplars

This demo showcases **Clarvynn's telemetry control plane** with real Flask applications. Experience how Clarvynn governs HTTP metrics and traces with exemplars - **zero code changes required**.

## 🎯 What You'll See

- **Zero code changes** - Flask apps run normally with Clarvynn governance
- **Controlled distributed tracing** - See requests flow across 3 microservices
- **Exemplars in action** - Click rhombus points to jump from metrics to traces
- **Production-ready telemetry** - Industry-standard Prometheus + Grafana + Tempo

## 🏗️ Architecture

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

## 🚀 Quick Start

### Prerequisites
- **Docker** (for LGTM observability stack)
- **Python 3.8+** (for Flask applications)
- **Clarvynn binary** (download from [releases](https://github.com/clarvynn/clarvynn/releases))

### Step 1: Start LGTM Stack
```bash
./start-lgtm-stack.sh
```

### Step 2: Set Up Python Environment
```bash
./setup-python-env.sh
```

### Step 3: Run Flask Services (3 terminals)

**Terminal 1 - Server A (Main API):**
```bash
source clarvynn-demo-env/bin/activate
clarvynn run gunicorn clarvynn_examples.server_a:app -w 2 --threads 2 -b 127.0.0.1:6000 --config custom.yaml --profile server-a-prod
```

**Terminal 2 - Server B (Greeting Service):**
```bash
source clarvynn-demo-env/bin/activate
clarvynn run uwsgi --ini clarvynn_examples/http_b.ini --workers 1 --threads 1 --config custom.yaml --profile server-b-prod
```

**Terminal 3 - Server C (Name Service):**
```bash
source clarvynn-demo-env/bin/activate
clarvynn run python clarvynn_examples/server_c.py --config custom.yaml --profile server-c-prod
```

### Step 4: Generate Traffic
```bash
./generate-traffic.sh
```

### Step 5: Verify Exemplars
```bash
./verify-exemplars.sh
```

### Step 6: View Exemplars
- **Grafana:** http://localhost:3000 (admin/admin) → Dashboards → "🚀 Clarvynn Application Monitoring"
- **Prometheus:** http://localhost:9090 → Query: `http_server_duration_milliseconds_bucket` → Graph tab → Enable "Show exemplars"

## 💎 What You'll Experience

### Exemplars in Action
- **Rhombus-shaped points** on histogram charts in Grafana
- **Click rhombus points** → Jump directly to distributed traces
- **Zero code changes** in Flask applications

### Key Metrics (with Exemplars)
- `http_server_duration_milliseconds_bucket` - Response time histograms
- `http_server_request_size_bytes_bucket` - Request size distributions
- `http_server_response_size_bytes_bucket` - Response size distributions

### Distributed Tracing
- **Server A** calls **Server B** + **Server C**
- See complete request flow in Tempo
- Automatic trace correlation via exemplars

## 🎯 Demo Value

### Technical Benefits
- **Zero code changes** - Flask apps run normally
- **Governed telemetry** - Clarvynn controls what gets emitted
- **Distributed tracing** - See requests flow across services
- **Exemplar correlation** - Direct links from metrics to traces

### Business Benefits
- **Faster troubleshooting** - From hours to minutes
- **No development overhead** - Zero code changes needed
- **Better user experience** - Proactive issue detection
- **Reduced operational costs** - Efficient problem resolution

## 🛑 Stopping the Demo

```bash
# Stop Flask applications (Ctrl+C in each terminal)
./stop-lgtm-stack.sh
```

## 📚 Learn More

- **Complete Guide:** [CLARVYNN_DEMO.md](CLARVYNN_DEMO.md)
- **Clarvynn Website:** https://www.clarvynn.io

---

**🚀 Experience governed telemetry with Clarvynn - no code changes required!**
