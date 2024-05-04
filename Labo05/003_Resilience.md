# Task 3 - Add and exercise resilience

By now you should have understood the general principle of configuring, running and accessing applications in Kubernetes. However, the above application has no support for resilience. If a container (resp. Pod) dies, it stops working. Next, we add some resilience to the application.

## Subtask 3.1 - Add Deployments

In this task you will create Deployments that will spawn Replica Sets as health-management components.

Converting a Pod to be managed by a Deployment is quite simple.

  * Have a look at an example of a Deployment described here: <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>

  * Create Deployment versions of your application configurations (e.g. `redis-deploy.yaml` instead of `redis-pod.yaml`) and modify/extend them to contain the required Deployment parameters.

  * Again, be careful with the YAML indentation!

  * Make sure to have always 2 instances of the API and Frontend running. 

  * Use only 1 instance for the Redis-Server. Why?

    > Car sinon les données ne seront pas cohérentes. Si on a plusieurs instances de Redis, chaque instance aura sa propre base de données et les données affichées changeront en fonction de l'instance qui répond.

  * Delete all application Pods (using `kubectl delete pod ...`) and replace them with deployment versions.

  * Verify that the application is still working and the Replica Sets are in place. (`kubectl get all`, `kubectl get pods`, `kubectl describe ...`)

## Subtask 3.2 - Verify the functionality of the Replica Sets

In this subtask you will intentionally kill (delete) Pods and verify that the application keeps working and the Replica Set is doing its task.

Hint: You can monitor the status of a resource by adding the `--watch` option to the `get` command. To watch a single resource:

```sh
$ kubectl get <resource-name> --watch
```

To watch all resources of a certain type, for example all Pods:

```sh
$ kubectl get pods --watch
```

You may also use `kubectl get all` repeatedly to see a list of all resources.  You should also verify if the application stays available by continuously reloading your browser window.

  * What happens if you delete a Frontend or API Pod? How long does it take for the system to react?
    > Le pod est supprimé et un nouveau pod est créé pour le remplacer. Cela prend quelques secondes. (pour un pod API par exemple il suffit de 3 secondes pour qu'un nouveau pod soit créé et prêt à répondre aux requêtes.)
    
  * What happens when you delete the Redis Pod?

    > Le pod est supprimé et un nouveau pod est créé pour le remplacer. Par contre, les données sont perdues car les données sont stockées dans le pod et non dans un volume persistant.
    
  * How can you change the number of instances temporarily to 3? Hint: look for scaling in the deployment documentation

    ```bash
    kubectl scale deployment api-deployment --replicas=3
    ```
    
  * What autoscaling features are available? Which metrics are used?

    > Il existe deux types d'autoscaling dans Kubernetes : Vertical et Horizontal. On peut mettre en place un autoscaling basé sur la métrique CPU ou mémoire. Kubernetes permet aussi de faire du scaling basé sur des events (KEDA) ou sur un cronjob (par exemple, réduire les ressources la nuit).
    
  * How can you update a component? (see "Updating a Deployment" in the deployment documentation)

    - On peut utiliser la commande `kubectl set image deployment/<DEPLOYMENT_NAME> <CONTAINER_NAME>=<NEW_IMAGE>` pour mettre à jour un composant. 
    - Ou bien on peut modifier le fichier de configuration du déploiement et appliquer les changements avec `kubectl apply -f <DEPLOYMENT_FILE>`. 
    - On peut aussi utiliser l'éditeur de texte pour modifier le fichier de configuration directement dans le cluster avec `kubectl edit deployment <DEPLOYMENT_NAME>`.

## Subtask 3.3 - Put autoscaling in place and load-test it

On the GKE cluster deploy autoscaling on the Frontend with a target CPU utilization of 30% and number of replicas between 1 and 4. 

Load-test using Vegeta (500 requests should be enough).

> [!NOTE]
>
> - The autoscale may take a while to trigger.
>
> - If your autoscaling fails to get the cpu utilization metrics, run the following command
>
>   - ```sh
>     $ kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
>     ```
>
>   - Then add the *resources* part in the *container part* in your `frontend-deploy` :
>
>   - ```yaml
>     spec:
>       containers:
>         - ...:
>           env:
>             - ...:
>           resources:
>             requests:
>               cpu: 10m
>     ```
>

## Deliverables

Document your observations in the lab report. Document any difficulties you faced and how you overcame them. Copy the object descriptions into the lab report.

> Le scaling automatique est plutôt rapide, il est tout de suite passé de 1 instance à 4 instances lorsque la charge a augmenté. Par contre, il est un peu lent à redescendre à 1 instance lorsque la charge diminue. Il faut attendre quelques minutes pour que le scaling automatique se fasse. Malgré la configuration de deployment à 2 instances, si dans la scaling policy le minimum est à 1, il va quand même redescendre à 1 instance si la charge est inférieure à 30%.


```````sh
$ kubectl describe pods
Name:             api-deployment-664fbdf7d9-xr9zl
Namespace:        default
Priority:         0
Service Account:  default
Node:             gke-gke-cluster-1-default-pool-041bd2c2-tds4/10.172.0.4
Start Time:       Sat, 04 May 2024 15:02:50 +0200
Labels:           app=todo
                  component=api
                  pod-template-hash=664fbdf7d9
Annotations:      <none>
Status:           Running
IP:               10.32.1.14
IPs:
  IP:           10.32.1.14
Controlled By:  ReplicaSet/api-deployment-664fbdf7d9
Containers:
  api:
    Container ID:   containerd://304e2bd8ba66d2069d8e19218013d8f842e2c28d89a5b9d592cb8147e06bf302
    Image:          icclabcna/ccp2-k8s-todo-api
    Image ID:       docker.io/icclabcna/ccp2-k8s-todo-api@sha256:13cb50bc9e93fdf10b4608f04f2966e274470f00c0c9f60815ec8fc987cd6e03
    Port:           8081/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Sat, 04 May 2024 15:02:51 +0200
    Ready:          True
    Restart Count:  0
    Environment:
      REDIS_ENDPOINT:  redis-svc
      REDIS_PWD:       ccp2
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-tlv22 (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-tlv22:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason        Age   From               Message
  ----     ------        ----  ----               -------
  Normal   Scheduled     37m   default-scheduler  Successfully assigned default/api-deployment-664fbdf7d9-xr9zl to gke-gke-cluster-1-default-pool-041bd2c2-tds4
  Normal   Pulling       37m   kubelet            Pulling image "icclabcna/ccp2-k8s-todo-api"
  Normal   Pulled        37m   kubelet            Successfully pulled image "icclabcna/ccp2-k8s-todo-api" in 389ms (391ms including waiting)
  Normal   Created       37m   kubelet            Created container api
  Normal   Started       37m   kubelet            Started container api
  Warning  NodeNotReady  88s   node-controller    Node is not ready


Name:             api-deployment-664fbdf7d9-xts8d
Namespace:        default
Priority:         0
Service Account:  default
Node:             gke-gke-cluster-1-default-pool-041bd2c2-490q/10.172.0.3
Start Time:       Sat, 04 May 2024 15:00:30 +0200
Labels:           app=todo
                  component=api
                  pod-template-hash=664fbdf7d9
Annotations:      <none>
Status:           Running
IP:               10.32.0.7
IPs:
  IP:           10.32.0.7
Controlled By:  ReplicaSet/api-deployment-664fbdf7d9
Containers:
  api:
    Container ID:   containerd://12a81abb39b42bb6afa81407e88e31c68c7af94e15c2a596b59bd014d124dd79
    Image:          icclabcna/ccp2-k8s-todo-api
    Image ID:       docker.io/icclabcna/ccp2-k8s-todo-api@sha256:13cb50bc9e93fdf10b4608f04f2966e274470f00c0c9f60815ec8fc987cd6e03
    Port:           8081/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Sat, 04 May 2024 15:00:41 +0200
    Ready:          True
    Restart Count:  0
    Environment:
      REDIS_ENDPOINT:  redis-svc
      REDIS_PWD:       ccp2
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-km58z (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-km58z:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  40m   default-scheduler  Successfully assigned default/api-deployment-664fbdf7d9-xts8d to gke-gke-cluster-1-default-pool-041bd2c2-490q
  Normal  Pulling    40m   kubelet            Pulling image "icclabcna/ccp2-k8s-todo-api"
  Normal  Pulled     39m   kubelet            Successfully pulled image "icclabcna/ccp2-k8s-todo-api" in 9.197s (9.198s including waiting)
  Normal  Created    39m   kubelet            Created container api
  Normal  Started    39m   kubelet            Started container api


Name:             frontend-deployment-859d5f8544-b62rb
Namespace:        default
Priority:         0
Service Account:  default
Node:             gke-gke-cluster-1-default-pool-041bd2c2-490q/10.172.0.3
Start Time:       Sat, 04 May 2024 15:35:31 +0200
Labels:           app=todo
                  component=frontend
                  pod-template-hash=859d5f8544
Annotations:      <none>
Status:           Running
IP:               10.32.0.10
IPs:
  IP:           10.32.0.10
Controlled By:  ReplicaSet/frontend-deployment-859d5f8544
Containers:
  frontend:
    Container ID:   containerd://c0e28c5e89517cb3be82e78cac2fe76fcf67a92a7144cc56ae3d9820ffd70f04
    Image:          icclabcna/ccp2-k8s-todo-frontend
    Image ID:       docker.io/icclabcna/ccp2-k8s-todo-frontend@sha256:5892b8f75a4dd3aa9d9cf527f8796a7638dba574ea8e6beef49360a3c67bbb44
    Port:           8080/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Sat, 04 May 2024 15:35:33 +0200
    Ready:          True
    Restart Count:  0
    Requests:
      cpu:  10m
    Environment:
      API_ENDPOINT_URL:  http://api-svc:8081
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-ccn6v (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-ccn6v:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  5m     default-scheduler  Successfully assigned default/frontend-deployment-859d5f8544-b62rb to gke-gke-cluster-1-default-pool-041bd2c2-490q
  Normal  Pulling    4m59s  kubelet            Pulling image "icclabcna/ccp2-k8s-todo-frontend"
  Normal  Pulled     4m58s  kubelet            Successfully pulled image "icclabcna/ccp2-k8s-todo-frontend" in 1.212s (1.213s including waiting)
  Normal  Created    4m58s  kubelet            Created container frontend
  Normal  Started    4m58s  kubelet            Started container frontend


Name:             frontend-deployment-859d5f8544-fk4d6
Namespace:        default
Priority:         0
Service Account:  default
Node:             gke-gke-cluster-1-default-pool-041bd2c2-tds4/10.172.0.4
Start Time:       Sat, 04 May 2024 15:35:31 +0200
Labels:           app=todo
                  component=frontend
                  pod-template-hash=859d5f8544
Annotations:      <none>
Status:           Running
IP:               10.32.1.19
IPs:
  IP:           10.32.1.19
Controlled By:  ReplicaSet/frontend-deployment-859d5f8544
Containers:
  frontend:
    Container ID:   containerd://5f6116cab496ca889acf7def021d686ee18f5eaeb60d54e87fe142bf532e4b88
    Image:          icclabcna/ccp2-k8s-todo-frontend
    Image ID:       docker.io/icclabcna/ccp2-k8s-todo-frontend@sha256:5892b8f75a4dd3aa9d9cf527f8796a7638dba574ea8e6beef49360a3c67bbb44
    Port:           8080/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Sat, 04 May 2024 15:35:33 +0200
    Ready:          True
    Restart Count:  0
    Requests:
      cpu:  10m
    Environment:
      API_ENDPOINT_URL:  http://api-svc:8081
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-gzsrh (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-gzsrh:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason        Age    From               Message
  ----     ------        ----   ----               -------
  Normal   Scheduled     5m     default-scheduler  Successfully assigned default/frontend-deployment-859d5f8544-fk4d6 to gke-gke-cluster-1-default-pool-041bd2c2-tds4
  Normal   Pulling       4m59s  kubelet            Pulling image "icclabcna/ccp2-k8s-todo-frontend"
  Normal   Pulled        4m58s  kubelet            Successfully pulled image "icclabcna/ccp2-k8s-todo-frontend" in 376ms (378ms including waiting)
  Normal   Created       4m58s  kubelet            Created container frontend
  Normal   Started       4m58s  kubelet            Started container frontend
  Warning  NodeNotReady  88s    node-controller    Node is not ready


Name:             frontend-deployment-859d5f8544-vd6hp
Namespace:        default
Priority:         0
Service Account:  default
Node:             gke-gke-cluster-1-default-pool-041bd2c2-tds4/10.172.0.4
Start Time:       Sat, 04 May 2024 15:31:08 +0200
Labels:           app=todo
                  component=frontend
                  pod-template-hash=859d5f8544
Annotations:      <none>
Status:           Running
IP:               10.32.1.18
IPs:
  IP:           10.32.1.18
Controlled By:  ReplicaSet/frontend-deployment-859d5f8544
Containers:
  frontend:
    Container ID:   containerd://3d7174c03c47322cce3d548e11c1d5684f07ab8237823473e612e3fcec0086f5
    Image:          icclabcna/ccp2-k8s-todo-frontend
    Image ID:       docker.io/icclabcna/ccp2-k8s-todo-frontend@sha256:5892b8f75a4dd3aa9d9cf527f8796a7638dba574ea8e6beef49360a3c67bbb44
    Port:           8080/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Sat, 04 May 2024 15:31:11 +0200
    Ready:          True
    Restart Count:  0
    Requests:
      cpu:  10m
    Environment:
      API_ENDPOINT_URL:  http://api-svc:8081
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-dgjln (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-dgjln:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason        Age    From               Message
  ----     ------        ----   ----               -------
  Normal   Scheduled     9m23s  default-scheduler  Successfully assigned default/frontend-deployment-859d5f8544-vd6hp to gke-gke-cluster-1-default-pool-041bd2c2-tds4
  Normal   Pulling       9m21s  kubelet            Pulling image "icclabcna/ccp2-k8s-todo-frontend"
  Normal   Pulled        9m21s  kubelet            Successfully pulled image "icclabcna/ccp2-k8s-todo-frontend" in 594ms (597ms including waiting)
  Normal   Created       9m20s  kubelet            Created container frontend
  Normal   Started       9m20s  kubelet            Started container frontend
  Warning  NodeNotReady  88s    node-controller    Node is not ready


Name:             frontend-deployment-859d5f8544-z8bw9
Namespace:        default
Priority:         0
Service Account:  default
Node:             gke-gke-cluster-1-default-pool-041bd2c2-490q/10.172.0.3
Start Time:       Sat, 04 May 2024 15:35:31 +0200
Labels:           app=todo
                  component=frontend
                  pod-template-hash=859d5f8544
Annotations:      <none>
Status:           Running
IP:               10.32.0.11
IPs:
  IP:           10.32.0.11
Controlled By:  ReplicaSet/frontend-deployment-859d5f8544
Containers:
  frontend:
    Container ID:   containerd://0906b81b7bbd02ff6d5ba6435566fea5b01843180825a4c79a819404cca8b3b7
    Image:          icclabcna/ccp2-k8s-todo-frontend
    Image ID:       docker.io/icclabcna/ccp2-k8s-todo-frontend@sha256:5892b8f75a4dd3aa9d9cf527f8796a7638dba574ea8e6beef49360a3c67bbb44
    Port:           8080/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Sat, 04 May 2024 15:35:33 +0200
    Ready:          True
    Restart Count:  0
    Requests:
      cpu:  10m
    Environment:
      API_ENDPOINT_URL:  http://api-svc:8081
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-gp8rc (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-gp8rc:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  5m     default-scheduler  Successfully assigned default/frontend-deployment-859d5f8544-z8bw9 to gke-gke-cluster-1-default-pool-041bd2c2-490q
  Normal  Pulling    4m59s  kubelet            Pulling image "icclabcna/ccp2-k8s-todo-frontend"
  Normal  Pulled     4m58s  kubelet            Successfully pulled image "icclabcna/ccp2-k8s-todo-frontend" in 973ms (974ms including waiting)
  Normal  Created    4m58s  kubelet            Created container frontend
  Normal  Started    4m58s  kubelet            Started container frontend


Name:             redis-deployment-56fb88dd96-5p9sg
Namespace:        default
Priority:         0
Service Account:  default
Node:             gke-gke-cluster-1-default-pool-041bd2c2-tds4/10.172.0.4
Start Time:       Sat, 04 May 2024 15:05:51 +0200
Labels:           app=todo
                  component=redis
                  pod-template-hash=56fb88dd96
Annotations:      <none>
Status:           Running
IP:               10.32.1.15
IPs:
  IP:           10.32.1.15
Controlled By:  ReplicaSet/redis-deployment-56fb88dd96
Containers:
  redis:
    Container ID:  containerd://3f495381932c4df561061037dcc5549e647f691a75d64fcf3dcd75e06b642050
    Image:         redis
    Image ID:      docker.io/library/redis@sha256:f14f42fc7e824b93c0e2fe3cdf42f68197ee0311c3d2e0235be37480b2e208e6
    Port:          6379/TCP
    Host Port:     0/TCP
    Args:
      redis-server
      --requirepass ccp2
      --appendonly yes
    State:          Running
      Started:      Sat, 04 May 2024 15:05:53 +0200
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-tqrrj (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-tqrrj:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason        Age   From               Message
  ----     ------        ----  ----               -------
  Normal   Scheduled     34m   default-scheduler  Successfully assigned default/redis-deployment-56fb88dd96-5p9sg to gke-gke-cluster-1-default-pool-041bd2c2-tds4
  Normal   Pulling       34m   kubelet            Pulling image "redis"
  Normal   Pulled        34m   kubelet            Successfully pulled image "redis" in 381ms (382ms including waiting)
  Normal   Created       34m   kubelet            Created container redis
  Normal   Started       34m   kubelet            Started container redis
  Warning  NodeNotReady  88s   node-controller    Node is not ready
```````

```sh
$ kubectl describe services
Name:              api-svc
Namespace:         default
Labels:            app=todo
                   component=api
Annotations:       cloud.google.com/neg: {"ingress":true}
Selector:          app=todo,component=api
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.76.170.167
IPs:               10.76.170.167
Port:              api  8081/TCP
TargetPort:        8081/TCP
Endpoints:         10.32.0.7:8081
Session Affinity:  None
Events:            <none>


Name:                     frontend-svc
Namespace:                default
Labels:                   app=todo
                          component=frontend
Annotations:              cloud.google.com/neg: {"ingress":true}
Selector:                 app=todo,component=frontend
Type:                     LoadBalancer
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.76.162.118
IPs:                      10.76.162.118
LoadBalancer Ingress:     34.65.144.165
Port:                     frontend  80/TCP
TargetPort:               8080/TCP
NodePort:                 frontend  31987/TCP
Endpoints:                10.32.0.10:8080,10.32.0.11:8080
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>


Name:              kubernetes
Namespace:         default
Labels:            component=apiserver
                   provider=kubernetes
Annotations:       <none>
Selector:          <none>
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.76.160.1
IPs:               10.76.160.1
Port:              https  443/TCP
TargetPort:        443/TCP
Endpoints:         10.172.0.2:443
Session Affinity:  None
Events:            <none>


Name:              redis-svc
Namespace:         default
Labels:            component=redis
Annotations:       cloud.google.com/neg: {"ingress":true}
Selector:          app=todo,component=redis
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.76.173.254
IPs:               10.76.173.254
Port:              redis  6379/TCP
TargetPort:        6379/TCP
Endpoints:         
Session Affinity:  None
Events:            <none>
```

```sh
$ kubectl describe deployments.apps
Name:                   api-deployment
Namespace:              default
CreationTimestamp:      Sat, 04 May 2024 15:00:30 +0200
Labels:                 app=todo
                        component=api
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=todo,component=api
Replicas:               2 desired | 2 updated | 2 total | 1 available | 1 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=todo
           component=api
  Containers:
   api:
    Image:      icclabcna/ccp2-k8s-todo-api
    Port:       8081/TCP
    Host Port:  0/TCP
    Environment:
      REDIS_ENDPOINT:  redis-svc
      REDIS_PWD:       ccp2
    Mounts:            <none>
  Volumes:             <none>
  Node-Selectors:      <none>
  Tolerations:         <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Progressing    True    NewReplicaSetAvailable
  Available      False   MinimumReplicasUnavailable
OldReplicaSets:  <none>
NewReplicaSet:   api-deployment-664fbdf7d9 (2/2 replicas created)
Events:
  Type    Reason             Age                  From                   Message
  ----    ------             ----                 ----                   -------
  Normal  ScalingReplicaSet  41m                  deployment-controller  Scaled up replica set api-deployment-664fbdf7d9 to 2
  Normal  ScalingReplicaSet  22m (x2 over 32m)    deployment-controller  Scaled up replica set api-deployment-664fbdf7d9 to 3 from 2
  Normal  ScalingReplicaSet  7m59s (x2 over 26m)  deployment-controller  Scaled down replica set api-deployment-664fbdf7d9 to 2 from 3


Name:                   frontend-deployment
Namespace:              default
CreationTimestamp:      Sat, 04 May 2024 15:00:35 +0200
Labels:                 app=todo
                        component=frontend
Annotations:            deployment.kubernetes.io/revision: 2
Selector:               app=todo,component=frontend
Replicas:               4 desired | 4 updated | 4 total | 2 available | 2 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=todo
           component=frontend
  Containers:
   frontend:
    Image:      icclabcna/ccp2-k8s-todo-frontend
    Port:       8080/TCP
    Host Port:  0/TCP
    Requests:
      cpu:  10m
    Environment:
      API_ENDPOINT_URL:  http://api-svc:8081
    Mounts:              <none>
  Volumes:               <none>
  Node-Selectors:        <none>
  Tolerations:           <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Progressing    True    NewReplicaSetAvailable
  Available      False   MinimumReplicasUnavailable
OldReplicaSets:  frontend-deployment-67879ff5df (0/0 replicas created)
NewReplicaSet:   frontend-deployment-859d5f8544 (4/4 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  41m    deployment-controller  Scaled up replica set frontend-deployment-67879ff5df to 2
  Normal  ScalingReplicaSet  10m    deployment-controller  Scaled up replica set frontend-deployment-859d5f8544 to 1
  Normal  ScalingReplicaSet  10m    deployment-controller  Scaled down replica set frontend-deployment-67879ff5df to 1 from 2
  Normal  ScalingReplicaSet  10m    deployment-controller  Scaled up replica set frontend-deployment-859d5f8544 to 2 from 1
  Normal  ScalingReplicaSet  10m    deployment-controller  Scaled down replica set frontend-deployment-67879ff5df to 0 from 1
  Normal  ScalingReplicaSet  6m55s  deployment-controller  Scaled down replica set frontend-deployment-859d5f8544 to 1 from 2
  Normal  ScalingReplicaSet  6m9s   deployment-controller  Scaled up replica set frontend-deployment-859d5f8544 to 4 from 1


Name:                   redis-deployment
Namespace:              default
CreationTimestamp:      Sat, 04 May 2024 15:00:25 +0200
Labels:                 app=todo
                        component=redis
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=todo,component=redis
Replicas:               1 desired | 1 updated | 1 total | 0 available | 1 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=todo
           component=redis
  Containers:
   redis:
    Image:      redis
    Port:       6379/TCP
    Host Port:  0/TCP
    Args:
      redis-server
      --requirepass ccp2
      --appendonly yes
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Progressing    True    NewReplicaSetAvailable
  Available      False   MinimumReplicasUnavailable
OldReplicaSets:  <none>
NewReplicaSet:   redis-deployment-56fb88dd96 (1/1 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  41m   deployment-controller  Scaled up replica set redis-deployment-56fb88dd96 to 1
```

```sh
$ kubectl describe hpa             
Name:                                                  frontend-hpa
Namespace:                                             default
Labels:                                                app=todo
                                                       component=frontend
Annotations:                                           <none>
CreationTimestamp:                                     Sat, 04 May 2024 15:29:29 +0200
Reference:                                             Deployment/frontend-deployment
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  237% (24m) / 30%
Min replicas:                                          1
Max replicas:                                          4
Deployment pods:                                       4 current / 4 desired
Conditions:
  Type            Status  Reason            Message
  ----            ------  ------            -------
  AbleToScale     True    ReadyForNewScale  recommended size matches current size
  ScalingActive   True    ValidMetricFound  the HPA was able to successfully calculate a replica count from cpu resource utilization (percentage of request)
  ScalingLimited  True    TooManyReplicas   the desired replica count is more than the maximum replica count
Events:
  Type     Reason                   Age                From                       Message
  ----     ------                   ----               ----                       -------
  Warning  FailedGetResourceMetric  10m (x8 over 12m)  horizontal-pod-autoscaler  missing request for cpu
  Warning  FailedGetResourceMetric  10m (x6 over 12m)  horizontal-pod-autoscaler  No recommendation
  Normal   SuccessfulRescale        7m40s              horizontal-pod-autoscaler  New size: 1; reason: cpu resource utilization (percentage of request) below target
  Normal   SuccessfulRescale        6m54s              horizontal-pod-autoscaler  New size: 4; reason: cpu resource utilization (percentage of request) above target
```

```yaml
# redis-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-deployment
  labels:
    component: redis
    app: todo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: todo
      component: redis
  template:
    metadata:
      labels:
        component: redis
        app: todo
    spec:
      containers:
      - name: redis
        image: redis
        ports:
        - containerPort: 6379
        args:
        - redis-server 
        - --requirepass ccp2 
        - --appendonly yes
```

```yaml
# api-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
  labels:
    component: api
    app: todo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: todo
      component: api
  template:
    metadata:
      labels:
        component: api
        app: todo
    spec:
      containers:
      - name: api
        image: icclabcna/ccp2-k8s-todo-api
        ports:
        - containerPort: 8081
        env:
        - name: REDIS_ENDPOINT
          value: redis-svc
        - name: REDIS_PWD
          value: ccp2
```

```yaml
# frontend-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-deployment
  labels:
    component: frontend
    app: todo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: todo
      component: frontend
  template:
    metadata:
      labels:
        component: frontend
        app: todo
    spec:
      containers:
      - name: frontend
        image: icclabcna/ccp2-k8s-todo-frontend
        ports:
        - containerPort: 8080
        env:
        - name: API_ENDPOINT_URL
          value: http://api-svc:8081
        resources:
          requests:
            cpu: 10m
```

```yaml
# frontend-hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: frontend-hpa
  labels:
    component: frontend
    app: todo
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: frontend-deployment
  minReplicas: 1
  maxReplicas: 4
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 30
```
