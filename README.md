# Clarvynn Cost Savings Demo

**See 66-70% observability cost reduction in < 5 minutes.**

---

## Expected Results

| Metric | Without Clarvynn | With Clarvynn | Savings |
|--------|------------------|---------------|---------|
| **Traces Exported** | ~5,000 | ~1,500 | 70% ↓ |
| **Logs Exported** | ~16,000 | ~5,400 | 66% ↓ |
| **Error Count** | 989 | 989 | 0% loss |
| **Monthly Cost** | ~$28 | ~$10 | 66% ↓ |

> **Note:** This demo uses 30% error rate (conservative). Real production with <5% errors sees **90%+ savings**.

---

## Quick Start

### Prerequisites

```bash
# Install dependencies
pip install flask requests gunicorn
pip install opentelemetry-distro opentelemetry-exporter-otlp
pip install opentelemetry-instrumentation-logging
opentelemetry-bootstrap -a install
```

### Step 1: Start Infrastructure

```bash
./start-lgtm-stack.sh
```

- Grafana: http://localhost:3000 (admin/admin)
- Dashboard auto-loads: "Clarvynn Cost Savings Demo"

### Step 2: Baseline WITHOUT Clarvynn

```bash
# Terminal 1: Run app
./scripts/run-app.sh

# Terminal 2: Generate 5000 requests (deterministic, ~4 min)
./scripts/generate-traffic.sh
```

**Check Dashboard:**
- Monthly Cost: **~$28**
- Traces: **~5,000** (100%)
- Logs: **~16,000**
- Errors: **989**

**Screenshot this** 

### Step 3: Reset Data

```bash
# Stop app (Ctrl+C in Terminal 1)

# Reset LGTM stack for clean comparison
./stop-lgtm-stack.sh
./start-lgtm-stack.sh

# Dashboard will auto-load again
```

### Step 4: Enable Clarvynn

```bash
# Install (one-time)
pip install clarvynn

# Set 2 env vars:
export CLARVYNN_ENABLED=true
export CLARVYNN_POLICY_PATH=$(pwd)/policies/policy.yaml

# Run SAME script:
./scripts/run-app.sh

# Terminal 2: Generate same traffic
./scripts/generate-traffic.sh
```

**Check Dashboard:**
- Monthly Cost: **~$10** (66% reduction!)
- Traces: **~1,500** (only critical traces exported!)
- Logs: **~5,400** (follow traces)
- Errors: **989** (same - 0% loss!)

**Screenshot this**

---

## What Just Happened?

**Clarvynn = OTEL + 2 env vars + 1 policy file**

The policy (`policies/policy.yaml`) defines what to capture:
- All errors (4xx, 5xx)
- All slow requests (>1s)
- 1% of routine traffic (statistical sampling)

Logs are buffered in memory and exported only when their associated span is exported. This ties log sampling to span sampling automatically.

---

## Understanding the Dashboard

**Key Panels:**

1.  **Estimated Monthly Cost**
    - Calculates ingestion cost based on actual data volume
    - Baseline: All requests → High cost
    - Clarvynn: Only critical + sampled → Lower cost

2.  **Trace/Log Export %**
    - Shows what % of traffic is being traced/logged
    - Green (low %) = efficient, Red (high %) = wasteful

3.  **Total Errors**
    - **MOST IMPORTANT:** Must be identical in both tests
    - Proves Clarvynn captures 100% of errors despite reducing overall data

4.  **Total Data Exported**
    - Actual count of traces and logs sent to backend
    - Should drop significantly with Clarvynn while errors stay constant

**Validation:**
- Compare the "Total Errors" number between baseline and Clarvynn runs
- If they match → You've proven zero data loss
- If they don't → Something's wrong (check if you reset data between tests)

---

## Policy File

```yaml
# policies/policy.yaml
sampling:
  base_rate: 0.01  # 1% of routine traffic

  conditions:
    - name: server_errors
      when: "status_code >= 500"
    
    - name: client_errors
      when: "status_code >= 400 AND status_code < 500"
    
    - name: slow_requests
      when: "duration_ms > 1000"
```

---

## Troubleshooting

**Dashboard not loading?**
```bash
# Check Grafana
open http://localhost:3000

# Restart stack if needed
./stop-lgtm-stack.sh
./start-lgtm-stack.sh
```

**Metrics not showing?**
```bash
# Check if app is running
curl http://localhost:8000/api/users

# Check OTEL collector
curl http://localhost:4318
```

---

**Questions?**
- GitHub: https://github.com/Clarvynn/Clarvynn
