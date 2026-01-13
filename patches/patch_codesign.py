#!/usr/bin/env python3
import re
import sys

with open(sys.argv[1], 'r') as f:
    content = f.read()

# Replace the _validate_provisioning_profile function to not fail
old_pattern = r'def _validate_provisioning_profile\([^)]*\):.*?(?=\ndef |\Z)'
new_func = """def _validate_provisioning_profile(
        *,
        platform_type,
        provisioning_profile,
        provisioning_profile_is_optional):
    # PATCHED: Skip provisioning profile validation for TrollStore/jailbreak builds
    return

"""

content = re.sub(old_pattern, new_func, content, flags=re.DOTALL)

with open(sys.argv[1], 'w') as f:
    f.write(content)

print("Patched successfully")
