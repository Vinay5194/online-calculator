
$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8000/")
$listener.Start()

Write-Output "Online Calculator running at http://localhost:8000/"

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $response = $context.Response
        $file = Join-Path $root "index.html"

        if ($context.Request.Url.AbsolutePath -eq "/" -and
            (Test-Path $file)) {

            $bytes = [System.IO.File]::ReadAllBytes($file)
            $response.StatusCode = 200
            $response.ContentType = "text/html; charset=utf-8"
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        }
        else {
            $response.StatusCode = 404
        }

        $response.Close()
    }
}
finally {
    $listener.Stop()
    $listener.Close()
}
