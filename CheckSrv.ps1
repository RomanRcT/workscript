$str=$args[0]
Get-Service -name "$str" | Select -ExpandProperty Name| Out-File -FilePath ./srvname.txt -Encoding 'ASCII'

