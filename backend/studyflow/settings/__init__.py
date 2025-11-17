import os
from dotenv import load_dotenv
load_dotenv()
env = os.getenv('DJANGO_ENV')
if env:
    if env.lower() in ('prod', 'production'):
        from .prod import *
    else:
        from .dev import *
else:
    if os.getenv('DEBUG', 'True') == 'True':
        from .dev import *
    else:
        from .prod import *
