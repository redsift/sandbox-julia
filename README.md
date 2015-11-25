# Sandbox for Julia

[![Docker Repository on Quay](https://quay.io/repository/redsift/sandbox-julia/status "Docker Repository on Quay")](https://quay.io/repository/redsift/sandbox-julia)

# Filesystem Layout and API

`SIFT_ROOT` Runs the sift made available in this path, defaults to `/run/dagger/sift`
`IPC_ROOT` Uses Nanomsg req/rep sockets in this path, defaults to `/run/dagger/ipc`. Node ordinality is used as the identity e.g. the 1st node in the DAG comunicates over `/run/dagger/ipc/0.sock`

Parameters are the node numbers you wish the bootstrap to execute.

