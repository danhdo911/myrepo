import csv
import ssl
from pyVim.connect import SmartConnect, Disconnect
from pyVmomi import vim
import atexit
import pandas as pd

def get_vcenter_info(si):
    content = si.RetrieveContent()
    data = []

    # Loop through datacenters
    for datacenter in content.rootFolder.childEntity:
        if isinstance(datacenter, vim.Datacenter):
            datacenter_name = datacenter.name
            
            # Loop through clusters in the datacenter
            for cluster in datacenter.hostFolder.childEntity:
                if isinstance(cluster, vim.ClusterComputeResource):
                    cluster_name = cluster.name

                    # # Loop through distributed switches in the datacenter
                    # for dvs in content.dvSwitchManager.dvSwitch:
                    #     if isinstance(dvs, vim.DistributedVirtualSwitch):
                    #         switch_name = dvs.name

                    #         # Loop through port groups
                    #         for port_group in dvs.portgroup:
                    #             if isinstance(port_group, vim.dvs.DistributedVirtualPortgroup):
                    #                 port_group_name = port_group.name
                    data.append({
                        "Datacenter": datacenter_name,
                        "Cluster": cluster_name,
                        # "Distributed Switch": switch_name,
                        # "Port Group": port_group_name
                    })

    return data

def main():
    # Disable SSL certificate verification
    context = ssl._create_unverified_context()
    
    # Connect to vCenter
    vc_server = '192.168.138.247'
    username = 'Administrator@vsphere.local'
    password = 'P@ssw0rd'
    
    si = SmartConnect(host=vc_server, user=username, pwd=password, port=443, sslContext=context)
    atexit.register(Disconnect, si)

    data = get_vcenter_info(si)

    # Convert data to DataFrame and save to CSV
    df = pd.DataFrame(data)
    df.to_csv('vcenter_info.csv', index=False)
    print("Data exported to vcenter_info.csv")

if __name__ == "__main__":
    main()
