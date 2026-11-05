# Infrastructure

Terraform for the dashboard on Azure Container Apps. The shared base (resource group, Container Apps environment, Container Registry, Log Analytics, Key Vault) and the API belong to [`baja-valle-service/infra`](https://github.com/raulvaldes-cetys/baja-valle-service/tree/master/infra); this configuration only reads them with data sources, so apply that one first.

It uses the same remote state storage as the service, with the key `web.tfstate`.

## What it creates

| Resource | Name | Notes |
|---|---|---|
| Container App | `ca-bajavalle-web` | Scale 0–1, 0.25 vCPU / 0.5 GiB, external HTTPS ingress on port 4321 |
| Managed identity | `id-bajavalle-web` | Only *AcrPull* on the registry; no Key Vault access |
| Managed identity | `id-bajavalle-web-github` | OIDC for GitHub Actions on `main`: *AcrPush* on the registry and *Contributor* on the dashboard app only |

The app gets `API_URL` (the API's public URL, read from its container app), `COOKIE_SECURE=true`, `HOST` and `PORT`. The dashboard holds no secrets: sessions are the API's own tokens in httpOnly cookies, and every API call is made from the Astro server.

## Usage

Requirements: [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.9 and the [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) signed in with `az login`. Your account needs *Storage Blob Data Contributor* on the state storage account and permission to create role assignments in the resource group.

1. Copy `terraform.tfvars.example` to `terraform.tfvars` (git-ignored) and fill it in. The registry name comes from `terraform -chdir=infra output container_registry` in baja-valle-service.
2. Build and push the first image, since the app is created with it:

   ```bash
   az acr login -n <registry-name>
   docker build --platform linux/amd64 -t <registry-name>.azurecr.io/baja-valle-web:<tag> .
   docker push <registry-name>.azurecr.io/baja-valle-web:<tag>
   ```

3. Apply:

   ```bash
   terraform -chdir=infra init
   terraform -chdir=infra plan
   terraform -chdir=infra apply
   ```

Terraform ignores the container image after the first deployment; CI deploys new images. The values for the deploy workflow's repository variables come from `terraform -chdir=infra output github_deploy` and are identifiers, not secrets.

After scaling to zero the first request takes several seconds, and longer if the API is also asleep.

## Checks

CI runs `terraform fmt -check`, `terraform validate`, `tflint` with the azurerm ruleset (`.tflint.hcl`) and Trivy, which fails on high or critical findings.
