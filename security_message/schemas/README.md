## Schema validation

Security message schema is written in [JSON Schema](https://json-schema.org/) to allow for easy validation.

The following example uses [Ajv](https://github.com/epoberezkin/ajv) to validate a message schema:

```bash
# install Ajv
npm install ajv
# validate message schema
#   replace 'message_to_validate.json' with your message
ajv validate -s message_to_validate.json -d messageRoot.json -r message*.json --all-errors
# expected output: message_to_validate.json valid
```
