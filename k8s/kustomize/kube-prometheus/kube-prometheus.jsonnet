//
// nimbus
// kube-prometheus deployment
//

local kp =
  (import 'kube-prometheus/main.libsonnet') +
  // Uncomment the following imports to enable its patches
  // expose prometheus metrics on k8s api server for use for autoscaling
  (import 'kube-prometheus/addons/external-metrics.libsonnet') +
  (import 'kube-prometheus/addons/all-namespaces.libsonnet') +
  {
    values+:: {
      common+: {
        namespace: 'monitoring',
      },
    },
  };


// kube-prometheus components
local kpComponents = [
  kp.prometheusOperator,

  // general monitoring components
  kp.alertmanager,
  kp.prometheus,
  kp.grafana,

  // exports metrics for k8s resources, api server and nodes
  kp.kubeStateMetrics,
  kp.kubernetesControlPlane,
  kp.nodeExporter,

  // adapts prometheus metrics for use in autoscaling pods
  kp.prometheusAdapter,

  // exports metrics derived using blackbox probes
  kp.blackboxExporter,
];

// compile all kube-prometheus manifests as a flatterned list
local kpManifestsJson = [
  kp.kubePrometheus.namespace,
  kp.kubePrometheus.prometheusRule,
] + std.flatMap(function(component) std.objectValues(component), kpComponents);

kpManifestsJson
