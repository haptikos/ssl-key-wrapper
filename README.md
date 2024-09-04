# SSL Key Wrapping Tool

This repository provides a tool to generate or wrap SSL keys for import into cloud providers such as Google Cloud or Oracle Cloud Infrastructure (OCI). The script can either generate a new private key or use an existing one, and it wraps the key using a public wrapping key provided by the cloud provider.

Wrapping algorithm: `RSA_OAEP_AES_SHA256`/`RSA_OAEP_3072_SHA256_AES_256`

## Features

- **Generate New SSL Private Key**: The script can generate a new SSL private key if one is not provided.
- **Wrap Existing SSL Key**: If a private key is provided, the script wraps the key using the cloud provider’s public wrapping key.
- **Supports Custom Key Sizes**: The default key size is 4096 bits, but this can be customized by setting the `KEY_SIZE` environment variable.
- **Base64 Output**: By default, the wrapped key and password are printed in base64 format. This behavior can be disabled by setting `PRINT_OUTPUT` to `false`.
- **Dockerized**: The tool is packaged in a Docker container, making it easy to use on any platform.

## Requirements

- **Docker**: Ensure Docker is installed on your system.
- **Linux/amd64 Platform**: The Dockerfile is configured to build the container for the linux/amd64 platform.

## Usage

### Build the Docker Image

To build the Docker image, run the following command:

```bash
docker build -t ssl-key-wrapper --platform linux/amd64 .
```

### Running the container

You can run the Docker container with the following command:

```bash
docker run --rm \
  -v /path/to/your/public_wrapping_key.pem:/opt/wrap_key/public_wrapping_key.pem \
  -v /path/to/your/private_key.pem:/opt/ssl/private_key.pem \
  -e KEY_PASSWORD=your_password \
  ssl-key-wrapper
```

### Environment Variables

- `PUBLIC_WRAPPING_KEY`: The public wrapping key provided by the cloud provider. This can either be mounted as a file (`/opt/wrap_key/public_wrapping_key.pem`) or provided via this environment variable.
- `KEY_PASSWORD`: The password for the private key if you are providing your own key (`private_key.pem`). This is required if you are not generating a new key.
- `KEY_SIZE`: The size of the SSL key to generate. The default is `4096` bits, but this can be customized by setting this variable.
- `PRINT_OUTPUT`: Set to `false` to disable printing of the generated key, password, and wrapped key in base64. By default, the output is printed.

### File Mounts

- `/opt/wrap_key/public_wrapping_key.pem`: The public wrapping key file from the cloud provider.
- `/opt/ssl/private_key.pem`: (Optional) Your existing private key file. If not provided, a new key will be generated.

### Example

*Generate a New SSL Key and Wrap It*

```bash
docker run --rm \
  -v /path/to/your/public_wrapping_key.pem:/opt/wrap_key/public_wrapping_key.pem \
  ssl-key-wrapper
```

*Wrap an Existing SSL Key*

```bash
docker run --rm \
  -v /path/to/your/public_wrapping_key.pem:/opt/wrap_key/public_wrapping_key.pem \
  -v /path/to/your/private_key.pem:/opt/ssl/private_key.pem \
  -e KEY_PASSWORD=your_password \
  ssl-key-wrapper
```

### Base64 output

By default, the script prints the following output in base64 format:

- The generated private key (if applicable).
- The generated key password (if a password was created).
- The wrapped key.

To suppress this output, set the `PRINT_OUTPUT` environment variable to `false`:
```bash
docker run --rm \
  -v /path/to/your/public_wrapping_key.pem:/opt/wrap_key/public_wrapping_key.pem \
  -v /path/to/your/private_key.pem:/opt/ssl/private_key.pem \
  -e KEY_PASSWORD=your_password \
  -e PRINT_OUTPUT=false \
  ssl-key-wrapper
```

## Output

The wrapped key will be saved as `key.bin` in the working directory inside the container (`/opt/wrap_key/`). The file can be retrieved using Docker’s volume mounts or other methods, depending on your specific setup.

```bash
$ ls folder/
public_wrapping_key.pem
$ docker run -e PRINT_OUTPUT=false  --rm -v $(pwd)/folder:/opt/wrap_key/ ssl-key-wrapper
Private key not found, generating a new private key.
Key password not provided, generating a new key password.
Key size not provided, using default size: 4096.
writing RSA key
Key wrapping process completed successfully.
$ ls folder/
key.bin                 private_key.der         private_key.pem         public_wrapping_key.pem t_aes.key               w_t_aes.key             wrapped_target_key_file
```
