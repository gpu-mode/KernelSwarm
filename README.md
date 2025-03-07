# KernelSwarm

## Lightouse details

Right now the Lighthouse is running on Digital Ocean on a $4/month droplet. If you'd like to be added please let us know and share your public ssh key.

The lighthouse is primarily responsible for keeping track of all nodes in the swarm.


## How to join the swarm

Idea of the setup is that a user
1. Click some button to get a client
2. We share the client with them
3. They run the client and it connects them to the swarm


## High level infra details
1. Lighthouse on Digital Ocean
2. Nebula VPN for swarm communication
3. Clients in shell scripts but soon should be docker containers
4. A fault tolerant PyTorch job that is responsible for the actual training
5. Share results in some public dashboard

## TBD

![swarm](./swarm.png)