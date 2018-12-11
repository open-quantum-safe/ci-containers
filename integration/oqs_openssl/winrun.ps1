#########################################
# OpenSSL integration test on Windows
#########################################

# edit these variables as needed (TODO: make these script arguments)

$download_and_build_liboqs = 1 # set to 0 to manually download and build
$liboqs_url = "https://github.com/open-quantum-safe/liboqs/archive/master.zip"
$liboqs_zip = "liboqs.zip"
$liboqs_path = "liboqs\liboqs-master" # base path when unzipping the downloaded package

$test_openssl_1_0_2 = 1 # set to 0 to skip 1.0.2
$download_and_build_openssl_1_0_2 = 1 # set to 0 to manually download and build
$openssl102_url = "https://github.com/open-quantum-safe/openssl/archive/OQS-OpenSSL_1_0_2-stable.zip"
$openssl102_zip = "openssl102.zip"
$openssl102_path = "openssl102\openssl-OQS-OpenSSL_1_0_2-stable" # base path when unzipping the downloaded package

$test_openssl_1_1_1 = 1 # set to 0 to skip 1.1.1
$download_and_build_openssl_1_1_1 = 1 # set to 0 to manually download and build
$openssl111_url = "https://github.com/open-quantum-safe/openssl/archive/OQS-OpenSSL_1_1_1-stable.zip"
$openssl111_zip = "openssl111.zip"
$openssl111_path = "openssl111\openssl-OQS-OpenSSL_1_1_1-stable" # base path when unzipping the downloaded package


#########################################
# setup
#########################################

$wc = New-Object System.Net.WebClient
$test_success = 0
$test_error = 1

# generate a Q.txt file with a Q char to pass to OpenSSL's s_client (to quit the session)
if (-Not (Test-Path -Path "Q.txt")) {
Add-Content -Path "Q.txt" -Value "Q"
}

function Install-OQS {
    param($path)
    New-Item -ItemType Directory -Force -Path $path\oqs\lib
    Copy-Item -Path $liboqs_path\VisualStudio\x64\Release\oqs.lib $path\oqs\lib\ -Recurse
    Copy-Item -Path $liboqs_path\VisualStudio\include $path\oqs -Recurse
}

#########################################
# OQS
#########################################

#download and build liboqs (master branch)
Write-Host "Downloading liboqs"
if ($download_and_build_liboqs -eq 1) {
    $wc.DownloadFile($liboqs_url, $liboqs_zip)
    if ($LASTEXITCODE -eq 1) {
        Write-Host -ForegroundColor Red "Failed downloading OQS from $liboqs_url"
        Exit $test_error
    }
    Expand-Archive $liboqs_zip
    if ($LASTEXITCODE -eq 1) {
        Write-Host -ForegroundColor Red "Failed unzipping OQS"
        Exit $test_error
    }
    msbuild $liboqs_path\VisualStudio\liboqs.sln --% /p:Configuration=Release;Platform=x64
    if ($LASTEXITCODE -eq 1) {
        Write-Host -ForegroundColor Red "Failed building OQS"
        Exit $test_error
    }
}

#########################################
# OpenSSL 1.0.2
#########################################

$success102 = 1 # flip to 0 on failure
$failures102 = "OpenSSL_1_0_2: "

if ($test_openssl_1_0_2) {
    #download openssl 1.0.2
    if ($download_and_build_openssl_1_0_2 -eq 1) {
        Write-Host "Downloading OpenSSL 1.0.2"
        $wc.DownloadFile($openssl102_url, $openssl102_zip)
        if ($LASTEXITCODE -eq 1) {
            Write-Host -ForegroundColor Red "Failed downloading OpenSSL 1.0.2 from $openssl102_url"
            Exit $test_error
        }
        Expand-Archive $openssl102_zip
        if ($LASTEXITCODE -eq 1) {
            Write-Host -ForegroundColor Red "Failed unzipping OpenSSL 1.0.2"
            Exit $test_error
        }
        Install-OQS($openssl102_path)
    }

    # build openssl 1.0.2 (static and DLL target)
    ForEach ($target102 in 'nt.mak', 'ntdll.mak') {
        if ($download_and_build_openssl_1_0_2 -eq 1) {
            cd $openssl102_path
            perl Configure VC-WIN64A
            ms\do_win64a
            nmake -f ms\$target102
            if ($LASTEXITCODE -eq 1) {
                Write-Host -ForegroundColor Red "Failed building OpenSSL 1.0.2 - $target102"
                Exit $test_error
            }
            cd $PSScriptRoot
        }
        $target102_path = "out32"
        if ($target102 -eq 'ntdll.mak') {
            $target102_path = $target102_path + 'dll' 
        }

        #run tests
        Write-Host "Redirecting stdout/stderr to $openssl102_path\client_std(out/err)_KEXALG_SIGALG.txt"
        ForEach ($sigalg in 'rsa') {
            Write-Host "Generating $sigalg key"
            Start-Process -FilePath "$openssl102_path\$target102_path\openssl.exe" -WorkingDirectory "$openssl102_path\" -WindowStyle Hidden -ArgumentList "req -x509 -new -newkey $sigalg -keyout $sigalg.key -out $sigalg.crt -nodes -subj `"/CN=oqstest`" -days 365 -config apps\openssl.cnf"
            Write-Host "Starting server with $sigalg cert"
            $server = Start-Process -FilePath "$openssl102_path\$target102_path\openssl.exe" -WorkingDirectory "$openssl102_path\" -WindowStyle Hidden -ArgumentList "s_server -cert $sigalg.crt -key $sigalg.key -HTTP -tls1_2" -PassThru 
            Start-Sleep -Seconds 2 # make sure server is up
            # TODO: check server is running correctly.
            ForEach ($kexalg in 'OQSKEM-DEFAULT', 'OQSKEM-DEFAULT-ECDHE') {
                # TODO: put cancel timer on operations to avoid blocking
                $stdout = "$openssl102_path\client_stdout_" + $kexalg + "_" + $sigalg + ".txt"
                $stderr = "$openssl102_path\client_stderr_" + $kexalg + "_" + $sigalg + ".txt"
                Write-Host "Starting client with $kexalg kex" # start client (Q.txt contains a 'Q' character to stop the client after the request)
                $client = Start-Process -FilePath "$openssl102_path\$target102_path\openssl.exe" -WorkingDirectory "$openssl102_path" -WindowStyle Hidden -ArgumentList "s_client -cipher $kexalg -connect localhost:4433" -RedirectStandardOutput "$stdout" -RedirectStandardError "$stderr" -RedirectStandardInput "Q.txt" -PassThru -Wait
                if ($client.HasExited -and $client.ExitCode -ne 0) {
                    Write-Host -ForegroundColor Red "$kexalg with $sigalg FAILED!"
                    $success102 = 0
                    $failures102 = $failures102 + $target102 + "/" + $kexalg + "/" + $sigalg + ", "
                }
            }
            Stop-Process $server
        }
    }
}

#########################################
# OpenSSL 1.1.1
#########################################

$success111 = 1 # flip to 0 on failure
$failures111 = "OpenSSL_1_1_1: "

if ($test_openssl_1_1_1) {
    #download and build openssl 1.1.1
    if ($download_and_build_openssl_1_0_2 -eq 1) {
        Write-Host "Downloading OpenSSL 1.1.1"
        $wc.DownloadFile($openssl111_url, $openssl111_zip)
        if ($LASTEXITCODE -eq 1) {
            Write-Host -ForegroundColor Red "Failed downloading OpenSSL 1.1.1 from $openssl111_url"
            Exit $test_error
        }
        Expand-Archive $openssl111_zip
        if ($LASTEXITCODE -eq 1) {
            Write-Host -ForegroundColor Red "Failed unzipping OpenSSL 1.1.1"
            Exit $test_error
        }
        Install-OQS($openssl111_path)
        cd $openssl111_path
        perl Configure VC-WIN64A
        nmake
        if ($LASTEXITCODE -eq 1) {
            Write-Host -ForegroundColor Red "Failed building OpenSSL 1.1.1"
            Exit $test_error
        }
        cd $PSScriptRoot
    }

    #run tests
    Write-Host "Redirecting stdout/stderr to $openssl111_path\client_std(out/err)_KEXALG_SIGALG.txt"
    ForEach ($sigalg in 'rsa', 'picnicl1fs') {
        Write-Host "Generating $sigalg key"
        Start-Process -FilePath "$openssl111_path\apps\openssl.exe" -WorkingDirectory "$openssl111_path\" -WindowStyle Hidden -ArgumentList "req -x509 -new -newkey $sigalg -keyout $sigalg.key -out $sigalg.crt -nodes -subj `"/CN=oqstest`" -days 365 -config apps\openssl.cnf"
        Write-Host "Starting server with $sigalg cert"
        $server = Start-Process -FilePath "$openssl111_path\apps\openssl.exe" -WorkingDirectory "$openssl111_path\" -WindowStyle Hidden -ArgumentList "s_server -cert $sigalg.crt -key $sigalg.key -HTTP -tls1_3" -PassThru 
        Start-Sleep -Seconds 2 # make sure server is up
        # TODO: check server is running correctly.
        ForEach ($kexalg in 'oqs_kem_default', 'frodo640aes', 'frodo640cshake', 'frodo976aes', 'frodo976cshake', 'newhope512cca', 'newhope1024cca', 'sidh503', 'sidh751', 'sike503', 'sike751', 'p256-oqs_kem_default', 'p256-frodo640aes', 'p256-frodo640cshake', 'p256-newhope512cca', 'p256-sidh503', 'p256-sike503') {
            # TODO: put cancel timer on operations to avoid blocking
            $stdout = "$openssl111_path\client_stdout_" + $kexalg + "_" + $sigalg + ".txt"
            $stderr = "$openssl111_path\client_stderr_" + $kexalg + "_" + $sigalg + ".txt"
            Write-Host "Starting client with $kexalg kex" # start client (Q.txt contains a 'Q' character to stop the client after the request)
            $client = Start-Process -FilePath "$openssl111_path\apps\openssl.exe" -WorkingDirectory "$openssl111_path" -WindowStyle Hidden -ArgumentList "s_client -curves $kexalg -connect localhost:4433" -RedirectStandardOutput "$stdout" -RedirectStandardError "$stderr" -RedirectStandardInput "Q.txt" -PassThru -Wait
            if ($client.HasExited -and $client.ExitCode -ne 0) {
                Write-Host -ForegroundColor Red "$kexalg with $sigalg FAILED!" # TODO: add to list of failing ciphers, to be printed at the end of the script
                $success111 = 0
                $failures111 = $failures111 + $kexalg + "/" + $sigalg + ", "
            }
        }
        Stop-Process $server
    }
}

#########################################
# Results
#########################################

if ($success102 -ne 1 -or $success111 -ne 1) {
    Write-Host -ForegroundColor Red "Tests failed:"
    if ($success102 -ne 1) {Write-Host -ForegroundColor Red "$failures102"}
    if ($success111 -ne 1) {Write-Host -ForegroundColor Red "$failures111"}
    Exit $test_error
} else {
    Write-Host -ForegroundColor Blue "All tests passed"
    Exit $test_success
}
