# cnp-aks-rbac

To create a cluster run:
./create-ad-app.sh <cluster-name (i.e. timw-aks)>

This will setup all the AD applications, the AKS cluster and the cluster role config

The cluster-admin role binding is setup to have:
1. a global group called aks-cluster-admins
2. a group for just the aks cluster called: <cluster-name>-cluster-admins

To add yourself to the global cluster admins group run:
```bash
OBJECT_ID=$(az ad user list --query "[?userPrincipalName=='$(az account show --query user.name -o tsv)'].objectId" -o tsv)
az ad group member add --group aks-cluster-admins --member-id ${OBJECT_ID}
```

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

echo 'aks-cluster-reader:'
az ad group create  --display-name aks-cluster-reader --mail-nickname aks-cluster-reader --query objectId -o tsv 
```

By default:
The `developers` group has global log reading permissions
The `aks-cluster-reader` group has global read (except secrets, roles and role bindings)
The `<team-name>-developers` group in the team namespace has read (same exceptions as global)

There is also some environment variables that can be set to enable more permissions for developers:
`DEVELOPERS_EDIT_TEAM_SCOPED` will give edit access in the team namespace
`DEVELOPERS_EDIT_GLOBAL_SCOPED` will give edit access globally