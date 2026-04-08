#IronDrive Unlocker

$LetraDrive = "D:"                 #Troque pela letra do disco atual que deseja acessar
$NomeArquivo = "TESTEBIT.txt"      #nome da Wordlist, na área de trabalho, você pode alterar do seu jeito

#Localiza o arquivo nodesktop ou onedrive
$Caminho = Join-Path $env:USERPROFILE "Desktop\$NomeArquivo"
if (-not (Test-Path $Caminho)) { $Caminho = Join-Path $env:USERPROFILE "OneDrive\Desktop\$NomeArquivo" }



if (-not (Test-Path $Caminho)) { 
    Write-Host "ERRO: Arquivo $NomeArquivo não foi encontrado!" -ForegroundColor Red
    exit 
}




#Lê as senhas com codificação UTF8 e limpando espaços/caracteres ocultos
$Senhas = Get-Content $Caminho -Encoding UTF8 | ForEach-Object { $_.Trim().Replace("`0", "") } | Where-Object { $_ -ne "" }

Write-Host "Iniciando tentativas de $($Senhas.Count) senhas no disco $LetraDrive" -ForegroundColor Cyan
Write-Host "Verificando..." -ForegroundColor Gray


foreach ($Senha in $Senhas) {
    #1 checagem de hardware (Evita rodar no 'vácuo')
    if (-not (Get-Volume -DriveLetter $LetraDrive.Replace(":","") -ErrorAction SilentlyContinue)) {
        Write-Host "`n[!] ERRO: SSD desconectado ou letra alterada!" -ForegroundColor Red
        break
    }

    
    
    #Exibe a senha atual para voce conferir os traços na tela
    Write-Host "Trying: [$Senha] " -NoNewline

    #2 Converte para securestring (Essencial para o comando -Password)
    $SecureString = $Senha | ConvertTo-SecureString -AsPlainText -Force

    #3 tenta o desbloqueio
    $Erro = $null
    Unlock-BitLocker -MountPoint $LetraDrive -Password $SecureString -ErrorAction SilentlyContinue -ErrorVariable Erro
    
    #Pausa técnica para o SSD processar a entrada
    Start-Sleep -Milliseconds 015

    #4 A prova real: O=o drive está acessível?
    
    if (Test-Path "$LetraDrive\") {
        Write-Host "`n`n====================================================================" -ForegroundColor Green
        Write-Host "SENHA ENCONTRADA: $Senha" -ForegroundColor Green
        Write-Host "=====================================================================" -ForegroundColor Green
        break
    } else {
        
        #se falhou, limpa o console para a próxima tentativa
        Write-Host " -> Incorreta" -ForegroundColor Gray
    }
}

Write-Host "`nProcesso finalizado."
pause

