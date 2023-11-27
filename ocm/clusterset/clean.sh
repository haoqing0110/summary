
#!/bin/bash

FILES="v1beta1-default.yaml
v1beta2-default.yaml
v1beta1-default-binding.yaml
v1beta2-default-binding.yaml
"

for f in $FILES
do
    oc delete -f $f
done
