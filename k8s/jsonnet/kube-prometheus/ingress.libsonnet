//
// nimbus
// kube-prometheus deployment
// ingress utility
//

// templates an k8s ingress resource for targeting the service with the given name and port.
//
// host: filters routed traffic to service targeting this hostname.
// serviceName: name of the service to route traffic to.
// servicePort: name / number of the port to route traffic to.
// ingressClass: ingress class specifies the ingress controller that handles the ingress.
// namespace: name of the k8s namespace to create the ingress in.
// backendProtocol: optional. The protocol the service uses to process requests. Defaults to HTTP.
function(host, svcName, svcPort, ingressClass, namespace, backendProtocol='HTTP') {
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: svcName,
    namespace: namespace,
    annotations: {
      'kubernetes.io/ingress.class': ingressClass,
      'nginx.ingress.kubernetes.io/backend-protocol': backendProtocol,
    },
  },
  spec: {
    rules: [
      {
        host: host,
        http: {
          paths: [
            {
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: svcName,
                  port: {
                    [if std.isNumber(svcPort) then 'number' else 'name']: svcPort,
                  },
                },
              },
            },
          ],
        },
      },
    ],
  },
}
