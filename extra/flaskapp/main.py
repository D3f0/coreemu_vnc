from flask import Flask, render_template, request, abort
import json
from subprocess import check_call


app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/set_geometry/', methods=['POST'])
def set_geometry():
    if not request.json:
        abort(400)
    geometry = '{}x{}'.format(request.json['width'], request.json['height'])
    with open('/root/.vnc/geometry', 'w') as fp:
        fp.write(geometry)
    return json.dumps(
        {
            "success": True,
            "geometry": geometry
        }
    )

@app.route('/start_vnc/', methods=['POST'])
def start_vnc():
    response = {
        'success': True
    }
    try:
        output = check_call('supervisorctl start vnc'.split())
        response['output'] = output
    except Exception as e:
        response['success'] = False
        response['error'] = str(e)
    return json.dumps(response)

@app.route('/stop_vnc/', methods=['POST'])
def stop_vnc():
    response = {
        'success': True
    }
    try:
        output = check_call('supervisorctl stop vnc'.split())
        response['output'] = output
    except Exception as e:
        response['success'] = False
        response['error'] = str(e)
    return json.dumps(response)


@app.route('/stop_vnc/', methods=['POST'])
def restart_vnc():
    response = {
        'success': True
    }
    try:
        output = check_call('supervisorctl stop vnc'.split())
        response['output'] = output
    except Exception as e:
        response['success'] = False
        response['error'] = str(e)
    return json.dumps(response)

def main():
    app.run(debug=True, host='127.0.0.1', port=3000)


if __name__ == '__main__':
    main()