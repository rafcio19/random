Get-AzureRmVM | Select-Object -Property Name, @{Name='IP';Expression={(Get-AzureRmNetworkInterface -name ($_.NetworkInterfaceIDs[0] -split "/")[-1] -ResourceGroupName $_.resourceGroupName).IpConfigurations.PrivateIpAddress}}| ft -AutoSize