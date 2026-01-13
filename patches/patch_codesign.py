#!/usr/bin/env python3
import re
import sys

with open(sys.argv[1], 'r') as f:
    content = f.read()

# Find the actual function signature and replace the whole function
# The function is called with: platform_prerequisites, provisioning_profile, rule_descriptor
old_pattern = r'def _validate_provisioning_profile\([^)]*\):.*?(?=\ndef |\ndef )'
new_func = """def _validate_provisioning_profile(**kwargs):
    # PATCHED: Skip provisioning profile validation for TrollStore/jailbreak builds
    return

"""

content = re.sub(old_pattern, new_func, content, flags=re.DOTALL)

with open(sys.argv[1], 'w') as f:
    f.write(content)

print("Patched successfully")
