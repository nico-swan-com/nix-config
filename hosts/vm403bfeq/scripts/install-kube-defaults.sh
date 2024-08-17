#!/bin/sh
# Set the timeout in seconds (e.g., 180 seconds for 3 minutes)
TIMEOUT=180

prerequisite() {
    if ! command -v kubectl &> /dev/null
    then
        echo "kubectl could not be found"
        exit 1
    fi

    if ! command -v helm &> /dev/null
    then
        echo "helm could not be found"
        exit 1
    fi

    echo "Both kubectl and helm are installed"

}

perpare() {
  mkdir -p $HOME/.config/k0s/etc
  mkdir -p $HOME/.config/k0s/volumes 
  mkdir -p $HOME/.config/k0s/registry 
}

deploy_k0s() {
    echo "Deploying k0s cluster to podman"
    echo
    podman run -d --name k0s --hostname k0s --privileged \
    	--cgroupns=host -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
    	-v /var/lib/k0s \
    	-v $HOME/.config/k0s/etc/config.yaml:/etc/k0s/config.yaml:rw \
    	-v $HOME/.config/k0s/volumes:/var/openebs/local:z \
    	-p 6443:6443  \
    	docker.io/k0sproject/k0s:v1.29.2-k0s.0 k0s controller --enable-worker --no-taints --enable-dynamic-config
    sleep 5 
}

deploy_registry() {
    echo "Deploying local container registry to podman"
    echo
    podman run --privileged -d --name registry --hostname registry \
    -p 5000:5000 \
    -v $HOME/.config/k0s/registry:/var/lib/registry \
    --restart=always registry:2
    sleep 5 
}

#Add kube config for local cluster
create_kube_config() {
    echo
    echo "Updating kube config"	
    kube_config_file="$HOME/.kube/local-k0s"
    new_value="https://localhost:6443"
    sed_query="s/^(\\s*    server\\s*:\\s*).*/\\1 https:\/\/localhost:6443/"
    podman exec k0s k0s kubeconfig admin | sed -r "$sed_query" | sed -r "s/Default/Local-cluster/g" > $kube_config_file
    chmod 600 $kube_config_file 
    echo "------"
    return
}

# Check if nodes are ready
check_nodes_ready() {
    local start_time=$(date +%s)
    echo
    echo "Waiting for Node to be Ready"
    while true; do
	echo    
	    echo "Pod status"    
	    podman exec k0s k0s kubectl get pods -A
        echo "-------"
	    echo
        echo "Node status"	
        nodes_status=$(podman exec k0s k0s kubectl get nodes -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}')
        if [[ "$nodes_status" == *"True"* ]]; then
            echo "Nodes are ready!"
            create_kube_config
	        break
        fi
	    echo "-------"

        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [[ $elapsed_time -ge $TIMEOUT ]]; then
            echo "Timeout: Nodes are not ready after $TIMEOUT seconds."
            echo " To monitor the pods and node status use the following commands"
	    echo "podman exec k0s k0s kubectl get nodes" 
            echo "podman exec k0s k0s kubectl get pods"
            exit 1
        fi
        echo "Waiting 10 seconds"
        sleep 10 
    done
}

add_helm_repos() {
   echo 	
   echo "Add Helm repositories"	 
   helm repo add metallb https://metallb.github.io/metallb
   helm repo add https://kubernetes.github.io/ingress-nginx 
   helm repo add openebs-internal https://openebs.github.io/charts
   helm repo add portainer https://portainer.github.io/k8s/
   helm repo update
   echo "-------"
}


install_metallb() {
   echo 	
   echo "Extention - Installing Metallb load balancer"	 
   helm -n metallb-system install metallb metallb/metallb --create-namespace

   local start_time=$(date +%s)
   while true; do
        pod_statuses=$(podman exec k0s k0s kubectl get pods -n "metallb-system" --no-headers -o custom-columns=":metadata.name,:status.phase")

        all_running=true
	    while read -r pod_name pod_status; do
            if [[ "$pod_status" != "Running" ]]; then
                echo "Waiting for Pod $pod_name be in a 'Running' state."
                all_running=false
                break
            fi
        done <<< "$pod_statuses"

        if $all_running; then
            echo "All pods are running."
            echo "Applying pool" 
	        kubectl apply -f metallb-pool.yaml
	        echo "-------"
            return
        fi
        
	    current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [[ $elapsed_time -ge $TIMEOUT ]]; then
            echo "Timeout: Metallb Pods are not running after $TIMEOUT seconds."
            exit 1
        fi
	sleep 5

   done

}
install_nginx_ingress() {
   echo 	
   echo "Extention - Installing NGINX Ingress controller"	 
   helm  upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace \
   --set controller.hostNetwork=true \
   --set rbac.create=true \
   --set controller.service.type=NodePort \
   --set controller.kind=DaemonSet

   local start_time=$(date +%s)
   while true; do
        pod_statuses=$(podman exec k0s k0s kubectl get pods -n "ingress-nginx" --no-headers -o custom-columns=":metadata.name,:status.phase")

        all_running=true
	    while read -r pod_name pod_status; do
            if [[ "$pod_status" != "Running" ]]; then
                echo "Waiting for Pod $pod_name be in a 'Running' state."
                all_running=false
                break
            fi
        done <<< "$pod_statuses"

        if $all_running; then
            echo "All pods are running."
            return
        fi
        
	current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [[ $elapsed_time -ge $TIMEOUT ]]; then
            echo "Timeout: Ingress NGINX Pods are not running after $TIMEOUT seconds."
            exit 1
        fi
	sleep 5

   done

}

install_openebs() {
   echo 	
   echo "Extention - Installing OpenEBS Storage"
   helm  install openebs openebs-internal/openebs --namespace openebs --create-namespace --version 3.9.0 \
    --set localprovisioner.hostpathClass.enabled="true" \
    --set localprovisioner.hostpathClass.isDefaultClass="true" \
    --set ndm.enabled="false"

   
   local start_time=$(date +%s)
   while true; do
        pod_statuses=$(podman exec k0s k0s kubectl get pods -n "openebs" --no-headers -o custom-columns=":metadata.name,:status.phase")

        all_running=true
	    while read -r pod_name pod_status; do
            if [[ "$pod_status" != "Running" ]]; then
                echo "Waiting for Pod $pod_name be in a 'Running' state."
                all_running=false
                break
            fi
        done <<< "$pod_statuses"

        if $all_running; then
            echo "All pods are running."
            return
        fi
        
	current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [[ $elapsed_time -ge $TIMEOUT ]]; then
            echo "Timeout: OpenEBS Pods are not running after $TIMEOUT seconds."
            exit 1
        fi
	sleep 5

   done

}

install_portainer() {
   echo 	
   echo "Application - Installing Portainer"
   helm  upgrade --install --create-namespace -n portainer portainer portainer/portainer \
    --set service.type=ClusterIP \
    --set tls.force=true \
    --set ingress.enabled=true \
    --set ingress.ingressClassName=nginx \
    --set ingress.annotations."nginx\.ingress\.kubernetes\.io/backend-protocol"=HTTPS \
    --set ingress.hosts[0].host=portainer.localhost \
    --set ingress.hosts[0].paths[0].path="/"\
    --set ingress.hosts[1].host=portainer.local.com \
    --set ingress.hosts[1].paths[0].path="/"

   
   local start_time=$(date +%s)
   while true; do
        pod_statuses=$(podman exec k0s k0s kubectl get pods -n "openebs" --no-headers -o custom-columns=":metadata.name,:status.phase")

        all_running=true
	    while read -r pod_name pod_status; do
            if [[ "$pod_status" != "Running" ]]; then
                echo "Waiting for Pod $pod_name be in a 'Running' state."
                all_running=false
                
                break
            fi
        done <<< "$pod_statuses"

        if $all_running; then
            echo "All pods are running."
            portainer_ip=$(kubectl get svc --namespace portainer portainer --template "")
            echo "http://$portainer_ip:9000"

            return
        fi
        
	current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [[ $elapsed_time -ge $TIMEOUT ]]; then
            echo "Timeout: OpenEBS Pods are not running after $TIMEOUT seconds."
            exit 1
        fi
	sleep 5

   done

}
prerequisite
#perpare
#deploy_k0s
check_nodes_ready
add_helm_repos
install_openebs
install_metallb
install_nginx_ingress
install_portainer
