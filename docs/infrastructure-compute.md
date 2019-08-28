# Deploying Haiku Compute Nodes

This guide will walk you through deploying Haiku compute nodes. In this document we will be using
DigitalOcean, however anything https://rexray.io supports should work in theory.

> DigitalOcean has a *fixed* limit of 7 volume attachments per node, and 10 volumes per **account**
> We're requesting to raise the account limit to 25.

## Common steps

**Install Base Requirements**
```
yum install git vim
curl -fsSL https://get.docker.com/ | sh
curl -sSL https://rexray.io/install | sh
systemctl enable docker
systemctl start docker
```

## Setup Docker Swarm

**On the first node of the region**

> XX.XX.XX.XX is the private IP of the instance

```
docker swarm init --advertise-addr XX.XX.XX.XX
```

**On each additional node of the region**

> XXXXX YYYYY are provided by the init above

```
docker swarm join --token XXXXX YYYYYY
```

## Setup Volume Driver

> Ensure you change the region from ams3 to the target region.

**Install rexray for DigitalOcean on each node**
```
docker plugin install rexray/dobs DOBS_CONVERTUNDERSCORES=true DOBS_REGION=ams3 DOBS_TOKEN=XXXX
```

## Assign Node Labels

**Shared Storage**

Our environment requires node labels to ensure containers sharing storage reside on the same host.
One node in the environment needs to have each of the following labels:

  * git
  * cdn
  * build

Labels can be applied to nodes via:
```
docker node update --label-add git=true (node_hostname)
```

**Node Sizes**

Smaller services target smaller nodes, larger services target larger nodes.
We label nodes as follows:

  * **small** 1 vCPU, 2GiB of RAM, 60 GiB SSD
  * **medium** 2 vCPU, 4GiB of RAM, 80 GiB SSD
  * **large** 4 vCPU, 8GiB of RAM, 160 GiB SSD

> As of this writing, we have two medium, one small.

```
docker node update --label-add tier=small (node_hostname)
```