$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8000/")
$listener.Start()

Write-Host "Online Calculator running at http://localhost:8000"

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()

        try {
            $path = $context.Request.Url.AbsolutePath.TrimStart("/")

            if ([string]::IsNullOrWhiteSpace($path)) {
                $path = "index.html"
            }

            # Only serve the three website files.
            if ($path -notin @("index.html", "style.css", "script.js")) {
                $context.Response.StatusCode = 404
                $context.Response.Close()
                continue
            }

            $file = Join-Path $root $path

            if (-not (Test-Path $file -PathType Leaf)) {
                $context.Response.StatusCode = 404
                $context.Response.Close()
                continue
            }

            $contentType = switch ([IO.Path]::GetExtension($file)) {
                ".html" { "text/html; charset=utf-8" }
                ".css"  { "text/css; charset=utf-8" }
                ".js"   { "application/javascript; charset=utf-8" }
            }

            $context.Response.ContentType = $contentType
            $bytes = [IO.File]::ReadAllBytes($file)
            $context.Response.ContentLength64 = $bytes.Length
            $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
        }
        catch {
            Write-Host $_
            $context.Response.StatusCode = 500
        }
        finally {
            $context.Response.Close()
        }
    }
}
finally {
    $listener.Stop()
    $listener.Close()
}
