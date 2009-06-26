spawn python "/var/django-projects/tdsurface/manage.py" "syncdb"
expect "(yes/no)" 
send "no"