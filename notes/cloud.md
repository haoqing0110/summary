```
lsblk
```
```
sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdc
```
```
sudo mount -o discard,defaults /dev/sdb /demo-mount
```
