## Schema tests

The following example uses [Ajv](https://github.com/jessedc/ajv-cli) to validate that messages in _samples.json_ conform to the schemas:

```bash
# install Ajv
npm install ajv
# run test.json on samples.json example
ajv test -s test.json -r ..\schemas\message*.json -d samples.json --valid
# expected output: samples.json passed test
```
