//
// nimbus
// kube-prometheus deployment
//

local ingress = import 'ingress.libsonnet';

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
      // disable HA on prometheus & alertmanager to reduce resource consumption
      prometheus+: {
        name: 'main',
        replicas: 1,
      },
      alertmanager+: {
        replicas: 1,
      },
    },
  };
// kube-prometheus components

local kpComponents = [
  kp.prometheusOperator,

  // general monitoring components
  kp.alertmanager,
  kp.prometheus,
  // patch grafana deploy to obtain admin credentials from secret
  kp.grafana {
    deployment+: {
      spec+: {
        template+: {
          spec+: {
            containers: [
              kp.grafana.deployment.spec.template.spec.containers[0] {
                env+: [
                  // expose admin user credentials to grafana from secret as env vars
                  {
                    name: configKey,
                    valueFrom: {
                      secretKeyRef: {
                        key: configKey,
                        name: 'kube-prometheus-grafana',
                      },
                    },
                  }
                  for configKey in [
                    'GF_SECURITY_ADMIN_USER',
                    'GF_SECURITY_ADMIN_PASSWORD',
                  ]
                ],
              },
            ],
          },
        },
      },
    },
  },

  // exports metrics for k8s resources, api server and nodes
  kp.kubeStateMetrics,
  kp.kubernetesControlPlane,
  kp.nodeExporter,

  // adapts prometheus metrics for use in autoscaling pods
  kp.prometheusAdapter,

  // exports metrics derived using blackbox probes
  kp.blackboxExporter,
];


// expose grafana service via internal ingress
local grafanaIngress = ingress(
  host='grafana.mrzzy.co',
  svcName=kp.grafana.service.metadata.name,
  svcPort=kp.grafana.service.spec.ports[0].name,
  ingressClass='ingress-nginx',
  namespace=kp.values.common.namespace,
);

// compile all kube-prometheus manifests as a flattened list
local kpManifestsJson = [
  kp.kubePrometheus.namespace,
  kp.kubePrometheus.prometheusRule,
  grafanaIngress,
] + std.flatMap(function(component) std.objectValues(component), kpComponents);

kpManifestsJson
