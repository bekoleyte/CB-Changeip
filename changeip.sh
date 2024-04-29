#!/bin/bash

while true; do
    read -p "sensorlere yeni server ipsini girip aktarilmasi saglandi mi? (yes/no): " response
    case $response in
        [Yy]*)
            sudo service cb-enterprise stop

            read -p "Yeni IP adresini girin: " new_ip
            read -p "Subnet mask'i girin (ornegin, 24): " subnet_mask

            # Ag arabiriminin adini bulma
            interface=$(ip route get 8.8.8.8 | awk -- '{printf $5}')

            # Yeni IP adresini ayarlama
            sudo nmcli con mod $interface ipv4.addresses $new_ip/$subnet_mask
            echo "IP adresleri guncelleniyor..."
            echo "Yeni IP adresi: $new_ip"
            sudo /usr/share/cb/cbservice cb-pgsql start
            chmod 777 /var/run/postgresql/
            sudo psql -d cb -p 5002 -c "UPDATE cluster_node_sensor_addresses SET address='$new_ip' WHERE id=0;"
            /usr/share/cb/cbservice cb-pgsql stop
            sudo /usr/share/cb/cbcheck firewall -a
            sudo service cb-enterprise start
            

            # Network sistemi yeniden baslatilsin mi?
            read -p "Network sistemi yeniden baslatilsin mi? (yes/no): " reboot_response
            case $reboot_response in
                [Yy]*)
                    sudo systemctl restart network
                    ;;
                [Nn]*)
                    echo "Network sistemi yeniden baslatilmayacak."
                    ;;
                *)
                    echo "Geçersiz yanit. Sistem yeniden baslatilmayacak."
                    ;;
            esac

            break
            ;;
        [Nn]*)
            echo "Tekrar adresleri girin."
            ;;
        *)
            echo "Geçersiz yanit lütfen 'yes' veya 'no' girin."
            ;;
    esac
done
