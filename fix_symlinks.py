#!/usr/bin/env python3
import os
import sys

if len(sys.argv) != 2:
    print(f"Usage: {sys.argv[0]} <sysroot_directory>")
    sys.exit(1)

sysroot = os.path.abspath(sys.argv[1])
lib_dir = os.path.join(sysroot, "usr/lib/aarch64-linux-gnu")

print("Scanning for .so files pointing to /etc/alternatives and fixing links...\n")

for subdir, _, files in os.walk(lib_dir):
    for f in files:
        filep = os.path.join(subdir, f)

        # Check if the file is a symlink and ends exactly with ".so"
        if os.path.islink(filep) and f.endswith(".so"):
            link_target = os.readlink(filep)

            # Check if the symlink points to /etc/alternatives
            if link_target.startswith("/etc/alternatives"):
                etc_link_path = os.path.join(sysroot, link_target.lstrip('/'))

                # Check if the /etc/alternatives link exists and resolve its target
                if os.path.islink(etc_link_path):
                    final_target = os.readlink(etc_link_path)
                    final_target_abs = os.path.abspath(os.path.join(os.path.dirname(etc_link_path), final_target))

                    # Prefix the sysroot to the final target if it starts with /usr/
                    if final_target_abs.startswith("/usr/"):
                        final_target_abs = os.path.join(sysroot, final_target_abs.lstrip('/'))
                    
                    # Resolve further if the final target is still a symlink
                    while os.path.islink(final_target_abs):
                        next_target = os.readlink(final_target_abs)
                        final_target_abs = os.path.abspath(os.path.join(os.path.dirname(final_target_abs), next_target))

                    print(f"Found .so file pointing to /etc/alternatives:")
                    print(f" - Symlink: {filep}")
                    print(f" - Target : {link_target}")
                    print(f" - Final Resolved Target: {final_target_abs}")

                    # Calculate the relative path within the sysroot
                    if final_target_abs.startswith(sysroot):
                        correct_relative_path = os.path.relpath(final_target_abs, os.path.dirname(filep))
                    else:
                        print(f"ERROR: The target {final_target_abs} is outside the sysroot!")
                        continue

                    # Update the symlink with the correct relative path
                    print(f"Updating symlink {filep} to point to {correct_relative_path}")
                    os.unlink(filep)
                    os.symlink(correct_relative_path, filep)
                    print(f" - Symlink updated to: {os.readlink(filep)}\n")

                    # Verify the link has been updated
                    if os.readlink(filep) == correct_relative_path:
                        print(f"✅ Symlink successfully updated: {filep}")
                    else:
                        print(f"❌ Symlink update failed: {filep} still points to {os.readlink(filep)}")
                else:
                    print(f"WARNING: /etc/alternatives link does not exist for {filep}\n")

