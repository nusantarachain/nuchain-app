# Nuchain Vault App

This is Nuchain App built with Flutter, based on Polkawallet.

# Run

You don't `flutter run` you `run` with `flavor`:

```
$ flutter run --flavor prod lib/main.dart
```

# Generate Model

Models written in flutter autogenerated by using json serialization library,
to regenerate the code please type:

```
$ ./etc/script/gen_code.sh
```

For delete existing conflicting output:

```
$ ./etc/script/gen_code.sh --delete-conflicting-outputs
```

