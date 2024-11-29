echo "Listing Disks:"
echo "------------------------------------"
lsblk
echo "------------------------------------"
echo "Choose which to flaten:"
read disk

echo "You have selected $disk. Are you sure? (yes/no)"
read confirmation
if [ "$confirmation" == "yes" ]; then
    dd if=/dev/zero of=$disk bs=1M status=progress
    echo $disk "was wiped"
else
    echo "Operation cancelled."
fi
