function create_records($subnet_prefix, $domain_name, $ZoneName)
{
    foreach ($i in 1..254)
    {
        
        $rec_ip = $subnet_prefix + "." + [string]$i
        $rec_name = "ip-" + $rec_ip.replace(".", "-")

        $command = "Add-DnsServerResourceRecordA -ZoneName $ZoneName -Name $rec_name -IPv4Address $rec_ip -CreatePtr -ComputerName $domain_name"
        Write-Output "Running $command"

        #Invoke-Expression $command
        

    }
    
}

create_records $args[0] $args[1] $args[2]