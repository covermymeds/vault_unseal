# vault-unseal

Playbooks for managing the Vault keys in your MacOS keychain.  These playbooks allow for the distribution, storage, and transmission of Hashicorp Vault keys.


# Requirements
 - Current Ansible version installed from pip or brew in your path.
 
 `brew install ansible`
 
 - Make (should be present by default on MacOS)

# Usage

After initializing Vault, five keys are provided and these playbooks provide a method of distributing those keys to individual keyholders and a method for those keyholders to transmit their keys to the Vault API for unsealing.

It is important in all the steps below to specify a unique name using the IDENTIFIER var.

## Distribution

After Vault is initialized five (5) unseal keys are displayed on the console.  These 5 keys should be copied into a file called `keyfile` in this directory.  The format of `keyfile` is one key per line.

After this file is in place, you can run:

`make distribute IDENTIFIER=your_unique_name`

This will iterate over the key holders defined in `group_vars/all` and copy one key to the each user's home directory on the jumphost. This process should be done with all key holders available to receive the keys ASAP as we don't want these keys to persist any longer than is needed.

NOTE:  the number of key holders MUST match the number of keys in the `keyfile`

## Storing Key

The key holders then run the following command to retrieve the key from the jumphost and store it in their MacOS keychain:

`make store-key IDENTIFIER=your_unique_name`

This stores the key in their MacOS keychain, validates what was stored matches what was distributed, then removes their key from the jumphost.

## Delete Keys

Once it has been confirmed that all keyholders have retrieved their keys, run the following command to delete the `keyfile`:

`make distribute-clean`

## Unseal Vault

To issue your unseal key to vault:

```
make unseal VAULT_HOST=FQDN_of_vault_instance
```

Replace the hostname with the one you want to unseal. This should parse the hostname to determine which key to send, then make the unseal api call.

