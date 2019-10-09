local k = import '1.14.7/k.libsonnet';
local utils = import 'utils.libsonnet';

local objs = {
  _config+:: {
    appname: 'nginx',
    namespace: 'default',
    port: 80,
    image: 'nginx:1.17',
  },

  demoApp+:: {
    serviceAccount:
      utils.newServiceAccount($._config.appname, $._config.namespace, null),

    clusterRole:
      utils.newClusterRole($._config.appname, [
        {apis: [''],
         res: ['pods', 'deployments'],
         verbs: ['get']},
      ], null),

    clusterRoleBinding:
      utils.newClusterRoleBinding($._config.appname, $._config.appname,$._config.namespace, $._config.appname, null),

    deployment:
      local d = utils.newDeployment($._config.appname, $._config.namespace, $._config.image, null, $._config.port);
      d 
        // Change default number of replicas
        + { spec+: { replicas: 2 }}
        // Add serviceAccount to deployment
        + k.apps.v1.deployment.mixin.spec.template.spec.withServiceAccountName($._config.appname),

    service:
      utils.newService($._config.appname, $._config.namespace, $._config.port),
    
    ingress:
      utils.newIngress($._config.appname, $._config.namespace, 'nginx.192.168.99.100.nip.io', '/', $._config.appname, $._config.port)
  },
};

utils.generate(objs)