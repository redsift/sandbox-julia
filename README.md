# Sandbox for Julia

[![Docker Repository on Quay](https://quay.io/repository/redsift/sandbox-julia/status "Docker Repository on Quay")](https://quay.io/repository/redsift/sandbox-julia)

# Filesystem Layout and API

`SIFT_ROOT` Runs the sift made available in this path, defaults to `/run/sandbox/sift`
`IPC_ROOT` Uses Nanomsg req/rep sockets in this path, defaults to `/run/sandbox/ipc`. Node ordinality is used as the identity e.g. the 1st node in the DAG comunicates over `/run/sandbox/ipc/0.sock`

Parameters are the node numbers you wish the run script to execute.

