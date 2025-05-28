from jinja2 import Template

def load_template(file_path):
    with open(file_path, 'r') as template_file:
        return Template(template_file.read(),trim_blocks=True, lstrip_blocks=True)