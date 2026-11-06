# Findings — Part 4 debug lab

The provided Windows workspace did not have Docker, kind, kubectl, Helm, or a
WSL distribution installed. I therefore could not honestly produce live
cluster output. The command/output snippets below are manifest evidence, not
claimed cluster observations. The same commands should be run on a provisioned
machine before submission.

## Defect 1

**Symptom:**

```text
gateway.env.BACKEND_URL = http://backend.default.svc:8080
```

**Cause:** The lab namespace is `debug-lab`, so the gateway looks for the
backend in `default`.

**Fix:** Changed the URL to `http://backend.debug-lab.svc:8080`.

**How I found it:** Compared the URL with `cluster-state/namespace.yaml` and
the gateway service DNS name used by the verifier.

## Defect 2

**Symptom:**

```text
RoleBinding reporter-read subjects[0].name = default
Deployment reporter serviceAccountName = reporter
```

**Cause:** The read role was bound to the wrong ServiceAccount.

**Fix:** Changed the RoleBinding subject to `reporter`.

**How I found it:** Compared the Deployment identity with the verifier's
`kubectl auth can-i list pods -n debug-lab
--as=system:serviceaccount:debug-lab:reporter` check.

## Defect 3

**Symptom:**

```text
Job.spec.template.spec.restartPolicy: Required value: valid values are
"OnFailure" or "Never"
```

**Cause:** Kubernetes Jobs cannot use `restartPolicy: Always`.

**Fix:** Changed the migration Job to `restartPolicy: Never`.

**How I found it:** Inspected the rendered Job against the batch/v1 Job API
validation rules.

## Defect 4

**Symptom:**

```text
metrics requests.cpu = 2
debug-lab-guardrails max.cpu = 1
```

**Cause:** The metrics pod exceeds the namespace LimitRange CPU ceiling.

**Fix:** Changed the request to `50m`.

**How I found it:** Compared `metrics.resources` with
`cluster-state/limits.yaml`.

## Defect 5

**Symptom:**

```text
The chart renders a metrics Deployment but no Service named metrics.
```

**Cause:** The metrics workload had no stable Service endpoint.

**Fix:** Added a ClusterIP Service selecting `app: metrics` on port 8080.

**How I found it:** Inventoried the rendered resources and compared them with
the lab description, which calls this workload a metrics service.

## Defect 6

**Symptom:**

```text
backend, gateway, worker, reporter, and metrics have readinessProbe entries
but no livenessProbe entries.
```

**Cause:** A process that becomes unhealthy after startup would remain
running and could continue receiving traffic because the chart had no
liveness-based restart signal.

**Fix:** Added `/healthz` liveness probes with a longer initial delay to all
five Deployments.

**How I found it:** Reviewed each Deployment template after the readiness
checks were present and compared the health policy across workloads.

## Reproduction commands

```bash
script -q part4-session.log
./scenario.sh reset
./scenario.sh up
kubectl -n debug-lab get pods
kubectl -n debug-lab describe pods
./scenario.sh verify
```
