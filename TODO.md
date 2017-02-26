## Set aws-cli command text to alias name. For example:

```
(lita) aws-cli ec2 describe-instances --profile 5fpro --alias 5fpro-ec2s
```

Execute by alias name:

```
(lita) aws-alias ec2s 5fpro-ec2s
```

List all alias names:

```
(lita) aws-alias-all
```

(output)

```
5fpro-ec2s :
  ec2 describe-instances --profile 5fpro
```
