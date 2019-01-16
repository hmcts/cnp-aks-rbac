# cnp-aks-rbac

To create a cluster run:
./create-ad-app.sh <cluster-name (i.e. timw-aks)>

This will setup all the AD applications, the AKS cluster and the cluster role config

The cluster-admin role binding is setup to have:
1. a global group called aks-cluster-admins
2. a group for just the aks cluster called: <cluster-name>-cluster-admins

There is then groups setup to mimic teams:
A one off run of this script was done:
```bash
echo 'developers:'
az ad group create  --display-name developers --mail-nickname developers --query objectId -o tsv 
echo 'cmc:'
az ad group create  --display-name cmc-developers --mail-nickname cmc-developers --query objectId -o tsv 
echo 'probate:'
az ad group create  --display-name probate-developers --mail-nickname probate-developers --query objectId -o tsv 
echo 'divorce:'
az ad group create  --display-name divorce-developers --mail-nickname divorce-developers --query objectId -o tsv 
```

The developers group has global log reading permissions