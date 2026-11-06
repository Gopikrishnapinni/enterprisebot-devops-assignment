# Enterprise Bot DevOps take-home

This repository contains the six assignment parts:

- `service/` is a small Python HTTP service.
- `chart/` deploys it with Helm.
- `setup.sh` creates/reuses the `demo` kind cluster and installs the release.
- `lab/` contains the supplied debugging exercise and the corrected chart.
- `ANSWERS.md` contains the Gateway API migration answer.

## Run and verify

On a machine with Docker, kind, kubectl, Helm, and Bash installed:

```bash
./setup.sh
./setup.sh
kubectl -n demo get deploy,svc,ingress
kubectl -n demo port-forward svc/demo-service 8080:80
curl -H 'Host: demo.local' http://127.0.0.1:8080/
curl -H 'Host: demo.local' http://127.0.0.1:8080/healthz
```

The first request returns the configured `APP_NAME`, `VERSION`, and pod
hostname. The second returns HTTP 200. The ingress controller can also be
tested through its exposed kind port with the same `Host` header.

For Part 4:

```bash
cd lab
./scenario.sh reset
./scenario.sh up
./scenario.sh verify
```

## Resource choices

The demo service requests 50m CPU and 64Mi memory, with limits of 200m CPU
and 128Mi memory. This is intentionally small for a single-threaded,
standard-library HTTP process while still giving the scheduler a realistic
request and preventing an accidental runaway process from consuming an
unbounded amount of node capacity. These are starting points, not production
capacity measurements; production values should be adjusted from workload
metrics.

## Deliberate omissions and production follow-up

I deliberately kept the service dependency-free and did not add TLS
certificates, persistent storage, autoscaling, a PodDisruptionBudget, network
policies, or external observability. Those omissions keep the exercise
focused, but mean the example is not suitable for an internet-facing
production deployment without additional controls. I would next add signed
image provenance and vulnerability scanning, TLS and DNS automation, resource
metrics with HPA, structured logs and tracing, network policies, admission
policy, a disruption budget, and a deployment strategy with rollback tests.
I would also add application-level tests and a CI pipeline that renders and
lints the chart before deploying it.

## How I used AI

I used GitHub Copilot (Copilot SDK in VS Code) to help inspect the assignment,
identify likely manifest defects, draft the small service and Helm templates,
and review the written documentation. I checked the generated files against
the assignment's exact keys and behavior and corrected the lab RBAC subject,
namespace-qualified backend URL, Job restart policy, resource request, and
missing metrics Service. The local environment did not have Docker, kind,
kubectl, or Helm installed, so I did not claim cluster command output that I
could not personally run.
