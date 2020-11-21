#! /bin/sh

# Wrap swift-format, so we can return 1 if there's warnings.
if swift-format -r -m lint Sources 2>&1 | grep 'warning'; then
echo "Linting failed"
exit 1
fi
