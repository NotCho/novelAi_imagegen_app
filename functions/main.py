import json
import subprocess
from firebase_functions import https_fn
from firebase_admin import initialize_app

initialize_app()

@https_fn.on_request()
def get_novelai_key(req: https_fn.Request) -> https_fn.Response:
    """
    Body: { "email": "...", "password": "..." }
    Returns: { "accessKey": "..." }
    """

    if req.method == 'OPTIONS':
        return https_fn.Response('', status=200, headers={
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS', 
        'Access-Control-Allow-Headers': 'Content-Type'
    })


    try:
        data = req.get_json(silent=True) or {}
        email = data.get('email')
        password = data.get('password')
        if not email or not password:
            return https_fn.Response(
                json.dumps({'error': 'email and password required'}),
                status=400
            )

        # one-time key 생성: 이메일+비번 해시
        proc_key = subprocess.run(
            ['python3', '-m', 'novelai_api', 'access_key', email, password],
            capture_output=True, text=True
        )
        if proc_key.returncode != 0:
            raise Exception(f'access_key failed: {proc_key.stderr}')
        one_time_key = proc_key.stdout.strip()

        # 결과 반환: one-time key만
        return https_fn.Response(
            json.dumps({'accessKey': one_time_key}),
            headers={'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'


}
        )

    except Exception as e:
        return https_fn.Response(
            json.dumps({'error': str(e)}),
            status=500,
            headers={'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'


}
        )
