# Virtual Coffee Shop Cloud Infrastructure

This repository contains a Terraform configuration that provisions cloud infrastructure for a virtual coffee shop chain. The goal is to create a scalable and cost-effective solution using AWS, with separate EC2 instances for the website (frontend) and backend (API), hosted in different subnets.

## Architecture Overview

The infrastructure includes the following components:

- A **Virtual Private Cloud (VPC)** with public and private subnets.
- An **EC2 instance** in the public subnet for the website (frontend).
- Another **EC2 instance** in the private subnet for the backend (API).
- An **Internet Gateway** for allowing internet access to the public subnet.
- **Security Groups** and **Network ACLs** to control traffic and enhance security.

### Architecture Diagram

Below is a high-level diagram of the architecture (placeholder for your diagram):

![Architecture Diagram](./diagrams/vpc_architecture.png)

## Components

### VPC

- A custom **Virtual Private Cloud** with CIDR block `10.0.0.0/16`.

### Subnets

- **Public Subnet** (`10.0.1.0/24`): Hosts the website EC2 instance (frontend).
- **Private Subnet** (`10.0.2.0/24`): Hosts the backend EC2 instance.

### Internet Gateway (IGW)

- Provides internet access to the public subnet.

### Route Tables

- **Public Route Table**: Routes traffic from the public subnet to the Internet Gateway.

### Security Groups

- **Frontend Security Group**: Allows inbound HTTP traffic (port 80) to the website.
- **Backend Security Group**: Allows traffic only from the public subnet (for backend communication).

### Network ACLs

- Provides an additional layer of control at the subnet level, ensuring that only specific traffic is allowed.

## Setup Instructions

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed on your machine.
- AWS credentials configured on your local machine (via environment variables or AWS credentials file).
- Access to an AWS account.
