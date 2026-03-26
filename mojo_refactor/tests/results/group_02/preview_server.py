#!/usr/bin/env python3
"""
Markdown Preview Server
A simple HTTP server to preview markdown files in browser
"""

import os
import http.server
import socketserver
from pathlib import Path

try:
    import markdown
    from markdown.extensions.codehilite import CodeHiliteExtension
    from markdown.extensions.fenced_code import FencedCodeExtension
    from markdown.extensions.tables import TableExtension
    MARKDOWN_AVAILABLE = True
except ImportError:
    MARKDOWN_AVAILABLE = False
    print("Warning: markdown package not installed. Install with: pip install markdown")
    print("Falling back to plain text display.")


class MarkdownHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        path = self.path.split('?')[0]
        
        if path == '/':
            self.send_directory_listing()
            return
        
        if path.endswith('.md'):
            self.send_markdown_file(path)
            return
        
        super().do_GET()
    
    def send_directory_listing(self):
        current_dir = Path('.')
        md_files = sorted(current_dir.glob('**/*.md'))
        
        html_content = """<!DOCTYPE html>
<html>
<head>
    <title>Markdown Files - Group 02 Test Results</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 40px; background: #f5f5f5; }
        h1 { color: #333; border-bottom: 2px solid #4CAF50; padding-bottom: 10px; }
        .file-list { list-style: none; padding: 0; }
        .file-list li { margin: 10px 0; padding: 15px; background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .file-list a { text-decoration: none; color: #2196F3; font-size: 16px; }
        .file-list a:hover { color: #1976D2; }
        .file-size { color: #666; font-size: 12px; margin-left: 10px; }
        .summary { background: #e8f5e9; border-left: 4px solid #4CAF50; padding: 15px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <h1>📋 Group 02 Test Results</h1>
    <div class="summary">
        <strong>Test Date:</strong> 2026-03-26<br>
        <strong>Files:</strong> 10 | <strong>Python Tests:</strong> 133 passed | <strong>Mojo Tests:</strong> 40 passed
    </div>
    <ul class="file-list">
"""
        
        for md_file in md_files:
            file_size = md_file.stat().st_size
            size_str = f"{file_size / 1024:.1f} KB" if file_size > 1024 else f"{file_size} B"
            html_content += f'        <li><a href="/{md_file}">📄 {md_file}</a><span class="file-size">({size_str})</span></li>\n'
        
        html_content += """    </ul>
</body>
</html>"""
        
        self.send_response(200)
        self.send_header('Content-type', 'text/html; charset=utf-8')
        self.end_headers()
        self.wfile.write(html_content.encode('utf-8'))
    
    def send_markdown_file(self, path):
        file_path = Path('.' + path)
        
        if not file_path.exists():
            self.send_error(404, "File not found")
            return
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            if MARKDOWN_AVAILABLE:
                extensions = [
                    'fenced_code',
                    'codehilite',
                    'tables',
                    'toc'
                ]
                html_content = markdown.markdown(content, extensions=extensions)
                
                full_html = f"""<!DOCTYPE html>
<html>
<head>
    <title>{file_path.name}</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
    <style>
        body {{ 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
            max-width: 1200px; 
            margin: 0 auto; 
            padding: 20px;
            background: #fff;
            line-height: 1.6;
        }}
        h1 {{ color: #1a73e8; border-bottom: 2px solid #1a73e8; padding-bottom: 10px; }}
        h2 {{ color: #333; border-bottom: 1px solid #ddd; padding-bottom: 8px; margin-top: 30px; }}
        h3 {{ color: #555; }}
        table {{ border-collapse: collapse; width: 100%; margin: 20px 0; }}
        th, td {{ border: 1px solid #ddd; padding: 12px; text-align: left; }}
        th {{ background: #f5f5f5; font-weight: bold; }}
        tr:nth-child(even) {{ background: #fafafa; }}
        tr:hover {{ background: #f0f7ff; }}
        code {{ background: #f4f4f4; padding: 2px 6px; border-radius: 4px; font-size: 14px; }}
        pre {{ background: #f6f8fa; padding: 16px; border-radius: 8px; overflow-x: auto; }}
        pre code {{ background: none; padding: 0; }}
        blockquote {{ border-left: 4px solid #1a73e8; margin: 0; padding-left: 20px; color: #666; }}
        .nav {{ margin-bottom: 20px; }}
        .nav a {{ color: #1a73e8; text-decoration: none; }}
        .nav a:hover {{ text-decoration: underline; }}
        .status-pass {{ color: #4CAF50; font-weight: bold; }}
        .status-fail {{ color: #f44336; font-weight: bold; }}
        .status-warn {{ color: #ff9800; font-weight: bold; }}
    </style>
</head>
<body>
    <div class="nav">
        <a href="/">← Back to file list</a>
    </div>
    {html_content}
    <script>hljs.highlightAll();</script>
</body>
</html>"""
            else:
                full_html = f"""<!DOCTYPE html>
<html>
<head>
    <title>{file_path.name}</title>
    <style>
        body {{ font-family: monospace; padding: 20px; white-space: pre-wrap; }}
    </style>
</head>
<body>
    <a href="/">← Back</a>
    <pre>{content}</pre>
</body>
</html>"""
            
            self.send_response(200)
            self.send_header('Content-type', 'text/html; charset=utf-8')
            self.end_headers()
            self.wfile.write(full_html.encode('utf-8'))
            
        except Exception as e:
            self.send_error(500, f"Error reading file: {str(e)}")


def main():
    print("=" * 60)
    print("Markdown Preview Server for Group 02 Test Results")
    print("=" * 60)
    print(f"\n📂 Serving directory: {os.getcwd()}")
    print(f"🌐 Open http://localhost:8000 in your browser")
    print("⏹️  Press Ctrl+C to stop\n")
    
    PORT = 8000
    
    with socketserver.TCPServer(("", PORT), MarkdownHandler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n\n✅ Server stopped.")


if __name__ == "__main__":
    main()
