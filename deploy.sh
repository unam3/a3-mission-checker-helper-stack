#!/bin/bash

# Mission Checker deploy script
function deploy {
    # Install virtualenv, uwsgi
    # http://flask.pocoo.org/docs/1.0/installation/#install-virtualenv
    # https://uwsgi-docs.readthedocs.io/en/latest/WSGIquickstart.html#installing-uwsgi-with-python-support
    sudo apt-get install python-virtualenv build-essential python-dev

    # Create necessary folders
    mkdir -p $1/uploads &&

    cd $1

    # Create virtual environment
    virtualenv -p /usr/bin/python2 venv

    # Activate the environment
    . venv/bin/activate

    pip install Flask
    pip install uwsgi

    echo -n "# Run app on bare flask in dev-mode. Must never be used on production machines.
cd $1; . venv/bin/activate; FLASK_APP=$1/src/app.py FLASK_ENV=development flask run

# Uwsgi-way
cd $1; . venv/bin/activate; uwsgi --pythonpath $1/src --virtualenv $1/venv --protocol http --socket 127.0.0.1:3331 --wsgi-file $1/src/app.py --callable app --processes 4 --threads 2 --stats 127.0.0.1:9111 --thunder-lock --logto $1/checker.log

# logs into console
cd $1; . venv/bin/activate; uwsgi --pythonpath $1/src --virtualenv $1/venv --protocol http --socket 127.0.0.1:3331 --wsgi-file $1/src/app.py --callable app --processes 4 --threads 2 --stats 127.0.0.1:9111 --thunder-lock

### Update process steps ###
# Pack uploads if any files and logs; put away
if ! [[ -z \"\$(ls -A $1/uploads)\" ]] || ! [[ -z \"\$(ls -A $1/checker.log)\" ]];
    then tar cfJ analizeIt.tar.xz --ignore-failed-read $1/uploads $1/checker.log;
fi

# Remove old files
#rm -rf $1/src $1/static $1/uploads/* $1/checker.log
rm -rf $1/*

# Unpack new version archive
dtrx checker_new_version.7z &&
mv -f checker_new_version/* $1/ &&
rm -rf checker_new_version/

" > $1/run_n_update_commands &&

    echo "instructions and commands was written to $1/run_n_update_commands"
}

if [[ -z $1 ]];
    then echo "first parameter must be absolute path to deploy destination folder";
    else deploy $1;
fi
