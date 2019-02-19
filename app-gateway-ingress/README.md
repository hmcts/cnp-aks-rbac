# Application gateway ingress

This section of the repo will setup an application gateway and install the ingress extensions
that allow the AG to be automatically configured by ingress rules.

Additional information:
https://github.com/Azure/application-gateway-kubernetes-ingress/blob/master/docs/tutorial.md

To setup run:

```
./setup-app-gateway-ingress.sh <aks-name>
```

This will create:
- an application gateway
- assign the Managed Identity permissions needed to manage the gateway
- install the ingress extensions required
- assign the Managed Identity to the ingress controller

To install a testing application run:

```
$ kubectl apply -f guestbook-all-in-one.yaml
$ kubectl apply -f ag.yaml
```

Once the app gateway has been reconfigured you can then view this in your browser
The following command retrieves the hostname of your application gateway:
```
export BASE_NAME=<your-cluster-name>
export NODE_RESOURCE_GROUP=$(az aks show -g core-infra-${BASE_NAME} --name ${BASE_NAME} --query nodeResourceGroup -o tsv)
az network public-ip show -g ${NODE_RESOURCE_GROUP} --name poc-ag --query dnsSettings.fqdn -o tsv
```

To see if the app gateway has been reconfigured you can tail the logs in the Debugging section

## Debugging

```
$ kubectl -n ag-poc get replicaset.apps

NAME                                      DESIRED   CURRENT   READY   AGE
app-gw-ingress-ingress-azure-564b847669   1         1         1       14h
frontend-654c699bc8                       3         3         3       13h
redis-master-57fc67768d                   1         1         1       13h
redis-slave-57f9f8db74                    2         2         2       13h
```

```
$ kubectl -n ag-poc logs -f replicaset.apps/app-gw-ingress-ingress-azure-564b847669

...
```

## Notes

If there is an error provisioning it doesn't seem to retry, I had to delete and recreate the ingress to force an update to happen. (Error occurred because the identity didn't have enough permissions in the resource group)

When I created the secret in the wrong namespace there was no failure logs the AG just wasn't updated, 
as soon as I created the secret is started working, I didn't have to change the ingress at all.

Do not run the ARM template for creating the application gateway after the ingress controller has taken
over management of it, the gateway is reset to the ARM definition and then the ingress rules need recreating in the cluster. If the application gateway needs an update (i.e. cipher or TLS protocol)

### TLS

You can create a self signed certificate for testing with:
```
$ openssl req -new -x509 -sha256 -newkey rsa:2048 -nodes -keyout key.pem -days 365 -out cert.pem
```

It needs to be uploaded as a Kubernetes secret
```
$ kubectl create secret tls guestbook-cert --key key.pem --cert cert.pem -n ag-poc
```

and then referenced in the ingress definition
```
spec:
  tls:
    - hosts:
      - d8383fdb-2ccf-4a21-ab72-efa5f91a6a3f.cloudapp.net
      secretName: guestbook-cert
```

and then applied:
```
$ kubectl apply -f ag-tls.yaml
```

## Remaining TODO:

- Pulling key / secret from key vault - (added a feature request for good integration: https://github.com/Azure/application-gateway-kubernetes-ingress/issues/103)
- Test multiple apps on the same app gateway
- Test multiple app gateways
- Test deleting apps
- Test on WAF_V2 SKU to see how long changes take to make
- ???