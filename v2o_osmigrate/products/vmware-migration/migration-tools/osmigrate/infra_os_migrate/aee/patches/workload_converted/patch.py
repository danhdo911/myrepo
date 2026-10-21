from pathlib import Path

path = Path("/usr/share/ansible/collections/ansible_collections/os_migrate/vmware_migration_kit/roles/import_workloads/tasks/nbdkit.yml")

old = """- name: Set fact for volume metadata
  ansible.builtin.set_fact:
    import_workloads_converted: "{{ volume_info_metadata.results[0].converted }}"
"""

new = """- name: Set fact for volume metadata
  ansible.builtin.set_fact:
    import_workloads_converted: >-
      {{
        (volume_info_metadata.results[0].converted | default(false) | bool)
        or
        (
          import_workloads_skip_conversion | default(false) | bool
          and
          (
            not import_workloads_cbt_sync | default(false) | bool
            or import_workloads_cutover | default(false) | bool
          )
        )
      }}
"""

content = path.read_text()

if old not in content:
    raise SystemExit("Target block not found. Please check nbdkit.yml manually.")

path.write_text(content.replace(old, new))
print("Patched:", path)
 