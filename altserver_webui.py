import http.server
import socketserver
import urllib.parse
import subprocess
import json
import os

PORT = 8081

HTML_CONTENT = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AltServer Web Installer</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-gradient-1: #0f172a;
            --bg-gradient-2: #1e1b4b;
            --glass-bg: rgba(255, 255, 255, 0.05);
            --glass-border: rgba(255, 255, 255, 0.1);
            --accent: #8b5cf6;
            --accent-hover: #7c3aed;
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
        }

        body {
            margin: 0;
            padding: 0;
            font-family: 'Outfit', sans-serif;
            background: linear-gradient(135deg, var(--bg-gradient-1), var(--bg-gradient-2));
            background-size: 400% 400%;
            animation: gradientBG 15s ease infinite;
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        @keyframes gradientBG {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        .container {
            width: 100%;
            max-width: 500px;
            padding: 2rem;
            background: var(--glass-bg);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid var(--glass-border);
            border-radius: 24px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            transform: translateY(0);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .container:hover {
            transform: translateY(-5px);
            box-shadow: 0 30px 60px -12px rgba(0, 0, 0, 0.6);
        }

        h1 {
            margin-top: 0;
            font-size: 2rem;
            font-weight: 600;
            text-align: center;
            background: linear-gradient(to right, #c4b5fd, #a78bfa);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 0.5rem;
        }

        p.subtitle {
            text-align: center;
            color: var(--text-muted);
            margin-bottom: 2rem;
            font-size: 0.95rem;
        }

        .form-group {
            margin-bottom: 1.5rem;
            position: relative;
        }

        label {
            display: block;
            margin-bottom: 0.5rem;
            font-size: 0.9rem;
            font-weight: 300;
            color: var(--text-muted);
        }

        input {
            width: 100%;
            padding: 12px 16px;
            background: rgba(0, 0, 0, 0.2);
            border: 1px solid var(--glass-border);
            border-radius: 12px;
            color: white;
            font-family: inherit;
            font-size: 1rem;
            outline: none;
            transition: all 0.3s ease;
            box-sizing: border-box;
        }

        input:focus {
            border-color: var(--accent);
            background: rgba(0, 0, 0, 0.4);
            box-shadow: 0 0 0 4px rgba(139, 92, 246, 0.1);
        }

        button {
            width: 100%;
            padding: 14px;
            background: var(--accent);
            color: white;
            border: none;
            border-radius: 12px;
            font-family: inherit;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        button:hover {
            background: var(--accent-hover);
            transform: scale(1.02);
        }

        button:active {
            transform: scale(0.98);
        }

        .terminal {
            margin-top: 2rem;
            background: rgba(0, 0, 0, 0.6);
            border: 1px solid var(--glass-border);
            border-radius: 12px;
            padding: 1rem;
            font-family: monospace;
            font-size: 0.85rem;
            color: #10b981;
            min-height: 100px;
            max-height: 200px;
            overflow-y: auto;
            display: none;
            white-space: pre-wrap;
        }

        .terminal.show {
            display: block;
            animation: fadeIn 0.5s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .loader {
            display: none;
            border: 3px solid rgba(255,255,255,0.1);
            border-top: 3px solid white;
            border-radius: 50%;
            width: 20px;
            height: 20px;
            animation: spin 1s linear infinite;
            margin: 0 auto;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>

    <div class="container">
        <h1>AltServer Installer</h1>
        <p class="subtitle">Sideload trackify-unsigned.ipa directly to your iPhone</p>

        <form id="installForm">
            <div class="form-group">
                <label for="udid">Device UDID</label>
                <div style="display: flex; gap: 8px;">
                    <input type="text" id="udid" name="udid" placeholder="e.g. 00008101-001234567890ABCD" required>
                    <button type="button" id="detectBtn" style="width: auto; font-size: 0.9rem; padding: 0 16px; background: rgba(139, 92, 246, 0.5);">Detect</button>
                </div>
            </div>
            
            <div class="form-group">
                <label for="apple_id">Apple ID</label>
                <input type="email" id="apple_id" name="apple_id" placeholder="your@email.com" required>
            </div>

            <div class="form-group">
                <label for="password">App-Specific Password</label>
                <input type="password" id="password" name="password" placeholder="abcd-efgh-ijkl-mnop" required>
            </div>

            <button type="submit" id="submitBtn">
                <span id="btnText">Install IPA</span>
                <div class="loader" id="loader"></div>
            </button>
        </form>

        <div class="terminal" id="terminal"></div>
    </div>

    <script>
        document.getElementById('detectBtn').addEventListener('click', async () => {
            const detectBtn = document.getElementById('detectBtn');
            const udidInput = document.getElementById('udid');
            const originalText = detectBtn.textContent;
            
            detectBtn.textContent = '...';
            detectBtn.disabled = true;
            
            try {
                const response = await fetch('/get-udid');
                const result = await response.json();
                
                if (result.udid) {
                    udidInput.value = result.udid;
                    detectBtn.textContent = 'Found!';
                    setTimeout(() => detectBtn.textContent = originalText, 2000);
                } else {
                    alert('Could not detect device. Is it plugged in and trusted?');
                    detectBtn.textContent = originalText;
                }
            } catch (err) {
                alert('Error detecting device.');
                detectBtn.textContent = originalText;
            } finally {
                detectBtn.disabled = false;
            }
        });

        document.getElementById('installForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const btnText = document.getElementById('btnText');
            const loader = document.getElementById('loader');
            const submitBtn = document.getElementById('submitBtn');
            const terminal = document.getElementById('terminal');
            
            // UI Loading state
            btnText.style.display = 'none';
            loader.style.display = 'block';
            submitBtn.disabled = true;
            terminal.classList.remove('show');
            terminal.textContent = 'Starting installation...\\n';
            terminal.classList.add('show');

            const formData = new FormData(e.target);
            const data = Object.fromEntries(formData.entries());

            try {
                const response = await fetch('/install', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(data)
                });
                
                const result = await response.json();
                
                if (result.success) {
                    terminal.textContent += '\\n✅ SUCCESS:\\n' + result.output;
                    terminal.style.color = '#10b981'; // Green
                } else {
                    terminal.textContent += '\\n❌ ERROR:\\n' + result.output;
                    terminal.style.color = '#ef4444'; // Red
                }
            } catch (err) {
                terminal.textContent += '\\n❌ CONNECTION ERROR:\\n' + err.message;
                terminal.style.color = '#ef4444';
            } finally {
                // Reset UI
                btnText.style.display = 'block';
                loader.style.display = 'none';
                submitBtn.disabled = false;
            }
        });
    </script>
</body>
</html>
"""

class AltServerHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(HTML_CONTENT.encode('utf-8'))
        elif self.path == '/get-udid':
            try:
                process = subprocess.Popen(['idevice_id', '-l'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
                out, err = process.communicate()
                udid = out.strip().split('\n')[0] if out.strip() else None
                if udid and "ERROR" not in udid:
                    self._send_json({"udid": udid})
                else:
                    self._send_json({"error": "No device found"})
            except Exception as e:
                self._send_json({"error": str(e)})
        else:
            super().do_GET()

    def do_POST(self):
        if self.path == '/install':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            try:
                data = json.loads(post_data.decode('utf-8'))
                udid = data.get('udid')
                apple_id = data.get('apple_id')
                password = data.get('password')

                if not all([udid, apple_id, password]):
                    self._send_json({"success": False, "output": "Missing required fields."})
                    return

                # Execute AltServer
                # Command: ./AltServer -u <udid> -a <apple_id> -p <password> trackify-unsigned.ipa
                command = [
                    "./AltServer", 
                    "-u", udid, 
                    "-a", apple_id, 
                    "-p", password, 
                    "trackify-unsigned.ipa"
                ]

                process = subprocess.Popen(
                    command,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    text=True,
                    cwd=os.getcwd()
                )
                
                output, _ = process.communicate()
                success = process.returncode == 0
                
                self._send_json({
                    "success": success,
                    "output": output
                })

            except Exception as e:
                self._send_json({"success": False, "output": str(e)})
        else:
            self.send_error(404)

    def _send_json(self, data):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode('utf-8'))

if __name__ == "__main__":
    with socketserver.TCPServer(("", PORT), AltServerHandler) as httpd:
        print(f"✨ AltServer WebUI running at http://localhost:{PORT}")
        print("Press Ctrl+C to stop.")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\\nShutting down server...")
