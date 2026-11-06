# Part 5 — Gateway API migration

- First inventory the current Ingress objects, annotations, TLS secrets,
  ingress classes, controllers, and application owners. Group them by
  behavior rather than migrating all 40 as one change. Export a baseline of
  routes and status/error metrics.
- Install the Gateway API CRDs and a Gateway controller in parallel with
  ingress-nginx. Create a Gateway with listeners for the existing HTTP and
  HTTPS names, validate certificate handling, and use a separate ingress
  class/controller configuration so existing traffic is untouched.
- Migrate one low-risk Ingress to an `HTTPRoute`, initially keeping the old
  Ingress. Compare routing, redirects, headers, timeouts, WebSockets, and
  access logs. Pay particular attention to annotations that have no direct
  Gateway API equivalent; replace them with controller policy resources or
  application configuration.
- Migrate in small batches, using synthetic checks and real traffic metrics.
  Shift DNS or load-balancer traffic only after the Gateway routes are
  accepted and healthy. Keep the old objects available for rollback.
- After all routes are stable, remove Ingress objects and ingress-nginx only
  after a soak period and an agreed rollback window.

Expected breakage includes annotation-specific rate limits and rewrites,
authentication integrations, TLS defaults, path matching differences, source
IP handling, controller-specific snippets, and differences in redirects or
timeouts. Invalid references and unsupported filters should be caught by
route status conditions and admission validation before traffic is shifted.
