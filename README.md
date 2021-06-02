# IBC Sample Between Hyperledger Fabric and Cosmos

This project is a sample for blockchain interoperability between Hyperledger Fabric and Cosmos-based blockchain using [Fabric-IBC](https://github.com/datachainlab/fabric-ibc) and [Relayer](https://github.com/datachainlab/relayer).

As a subject, token transfer using ICS-20 is used.

## Build

```
make build
make build-image
```

## Running the scenario

Token transfer can be observed as an end-to-end test.
To bring up a fabric network and cosmos, and establish an IBC connection between them, execute the following command:

```
make setup
```

Then, run the transfer scenario:

```
make transfer
```

Here's how to clean up:

```
make stop
make clean
```

## Fabric

### Chaincode

It uses the IBCApp provided by Fabric-IBC, to which you can add cosmos modules. We add some IBC modules, including ICS-20 `transfer.`

### Network

In this sample, the Fabric network has one application channel and only one organization.
Relayer has been given the identity of this organization and thus has access to its application channel.

To change the configs, see `/networks/fabric`.

## Cosmos

### Application

We use a simple application with IBC modules.

