## Usage

### Clone

```shell
$ git clone git@github.com:siddhpurakaran/infra_contracts.git
```

### Add .env file

```shell
Copy .env.local file into file named .env file
```

### Build

```shell
$ forge build
```

### Anvil

```shell
$ anvil --block-time 2
```

### Deploy

```shell
$ forge script script/DeployOracles.s.sol:DeployOracles --rpc-url http://127.0.0.1:8545
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
