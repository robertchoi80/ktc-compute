#!/usr/bin/python

# Get server and port list from controller and
# extract IP addresses from the response.
# Then send ping to these IPs to check if the port is active.
# With this test, we can test if routing is correct.
# Result shows servers and ports failed getting ping response.
# Reference http://four-eyes.net/2012/11/openstack-api-python-script-example/

import argparse
import getopt
import json
import sys
import urllib2
import os
import datetime

STATE_OK = 0
STATE_WARNING = 1
STATE_CRITICAL = 2
STATE_UNKNOWN = 3

def sendRequest(url, token=None, payload=None):

    """
    Make a request and send request.
    headers will be list of {key, value} dict.
    Returns response.
    """
    request = urllib2.Request(url)
    request.add_header("Content-type", "application/json")
    if token != None:
        request.add_header("X-Auth-Token", token)

    request = urllib2.urlopen(request, payload) 
    json_data = json.loads(request.read())

    request.close()
    return json_data

def getToken(url, user, tenant, password):

    """
    Returns a token to the user given a tenant,
    user name, password, and OpenStack API URL.
    """
    url = url + '/tokens'
    data = { 
        "auth":{
            "tenantName": tenant,
            "passwordCredentials":{
                 "username": user,
                 "password": password
          }
       }
    }
    jsonPayload = json.dumps(data)
    return sendRequest(url, payload=jsonPayload)

def getPorts(url, token):

    """
    Returns ports for the given tenant.
    """
    url = url + '/v2.0/ports'
    return sendRequest(url, token)

def getNetworks(url, token, interface):

    """
    Returns network name list
    """
    def _get_networks(url, token):
        url = url + '/v2.0/networks'
        return sendRequest(url, token)
 
    def _return_net_type(network):
        if network['name'].split('.')[-1] =='private':
            return 'eth1'
        return 'eth0'

    networks = _get_networks(url, token)
    networkNames = []
    for network in networks['networks']:
        net_type = _return_net_type(network)
        if interface == None or interface == net_type:
            networkNames.append(network['name'])
    return networkNames

def getServers(url, token, hostname):

    """
    Returns instances for the given tenant.
    """
    url = url + '/servers/detail?all_tenants=1'
    if hostname != None:
        url = url + ('&host=%s') % hostname
    return sendRequest(url, token)

def getActiveServers(url, token, hostname):

    """
    Returns active instances for the given tenant.
    """
    url = url + '/servers/detail?all_tenants=1&status=ACTIVE'
    if hostname != None:
        url = url + ('&host=%s') % hostname
    result = sendRequest(url, token)
    
    activeServers = []
    for server in result['servers']:
        if server['OS-EXT-STS:power_state'] == 1:
           activeServers.append(server)
    return {'servers': activeServers}

def getHypervisors(url, token):

    """
    Returns hypervisor list.
    """
    url = url + '/os-hypervisors'
    return sendRequest(url, token)

def isValidHypervisor(hypervisors, hostname):

    """
    Returns if the given hostname is valid.
    """
    for hypervisor in hypervisors['hypervisors']:
        if hypervisor['hypervisor_hostname'] == hostname:
            return True 
    return False

def checkPortStatus(ip):
    
    """
    Returns port active status with ping test.
    """
    cmd = 'ping -c 1 -W 2 ' + ip
    if os.system(cmd) == 0:
        return "ACTIVE"
    else:
        return "DOWN"

def getPortStatus(ports):

    """
    Returns status of all ports.
    """
    downPorts = []
    for port in ports['ports']:
        for ip in port['fixed_ips']:
            status = checkPortStatus(ip['ip_address'])
            if status == "DOWN":
                downPorts.append({'id': port['id'], 'ip': ip['ip_address']})
    return downPorts

def getPortDownServers(servers, networks):

    """
    Returns server port active status with ping test.
    """
    downServers = []
    for server in servers['servers']:
        for network in networks:
            try:
                for ip in server['addresses'][network]:
                    status = checkPortStatus(ip['addr'])
                    if status == "DOWN":
                        downServers.append({"id": server['id'], "name": server['name'], "ip": ip['addr']})
            except KeyError:
                # Pass if the network is not allocated for the VM
                continue
    return downServers

if __name__=="__main__":
    # Build our required arguments list
    parser = argparse.ArgumentParser()
    parser.add_argument("-u", "--user", help="The administrative user's name", type=str)
    parser.add_argument("-p", "--password", help="The administrative user's password", type=str)
    parser.add_argument("-t", "--tenant", help="The administrative user's tenant project", type=str)
    parser.add_argument("-e", "--endpoint", help="The Keystone API endpoint", type=str)
    parser.add_argument("-c", "--cnode", help="Full hostname of cnode to check.", type=str)
    parser.add_argument("-i", "--interface", help="Full hostname of cnode to check.", type=str)
    parser.add_argument("-r", "--threshold", help="Threshold for cnode failure(Max% of dead VMs)", type=int)
    args = parser.parse_args()

    # Validate arugments were given
    if type(args.endpoint) != type(str()):
        sys.stderr.write('Invalid URL: %s\n' % args.endpoint)
        parser.print_help()
        sys.exit(2)
    if type(args.tenant) != type(str()):
        sys.stderr.write('Invalid tenant: %s\n' % args.tenant)
        parser.print_help()
        sys.exit(2)
    if type(args.password) != type(str()):
        sys.stderr.write('Invalid password: %s\n' % args.password)
        parser.print_help()
        sys.exit(2)
    if type(args.user) != type(str()):
        sys.stderr.write('Invalid login: %s\n' % args.user)
        parser.print_help()
        sys.exit(2)
    if type(args.cnode) != type(str()):
        sys.stderr.write('Invalid cnode: %s\n' % args.cnode)
        parser.print_help()
        sys.exit(2)
    if type(args.interface) != type(str()):
        sys.stderr.write('Invalid interface: %s\n' % args.interface)
        parser.print_help()
        sys.exit(2)
    if type(args.threshold) != type(int()):
        sys.stderr.write('Invalid threshold: %s\n' % args.threshold)
        parser.print_help()
        sys.exit(2)


    # Get admin token
    adminToken = getToken(args.endpoint, args.user, args.tenant, args.password)
    adminTokenID = adminToken['access']['token']['id']
    adminTokenTenantID = adminToken['access']['token']['tenant']['id']

    # Get Quantum service endpoint
    for item in adminToken['access']['serviceCatalog']:
        if item['name'] == "quantum":
            adminQuantumURL = item['endpoints'][0]['adminURL']
        if item['name'] == "nova":
            adminNovaURL = item['endpoints'][0]['adminURL']

    # Validate arugments were given
    hypervisors = getHypervisors(adminNovaURL, adminTokenID)
    if args.cnode != None and (type(args.cnode) != type(str()) or
       isValidHypervisor(hypervisors, args.cnode) == False):
        sys.stderr.write('Invalid conde: %s\n\n' % args.cnode)
        parser.print_help()
        sys.exit(2)
    if args.interface != None and (args.interface != 'eth0' and
                       args.interface != 'eth1'):
        sys.stderr.write('Invalid interface name: %s\n\n' % args.interface)
        parser.print_help()
        sys.exit(2)
        

    # Get servers for given tenant
    allServers = getServers(adminNovaURL, adminTokenID, args.cnode)
    activeServers = getActiveServers(adminNovaURL, adminTokenID, args.cnode)
    networks = getNetworks(adminQuantumURL, adminTokenID, args.interface)
    portDownServers = getPortDownServers(activeServers, networks)

    # Generate sensu alerts
    numAll = len(allServers)
    numActive = len(activeServers)
    numDown = len(portDownServers)
    numRunning = numActive - numDown
    ratioRunning = numRunning / numAll * 100
    print "[VM Stats] All: %d, Active: %d, Running(Reachable): %d. runningRatio: %d%%" % (numAll, numActive, numRunning, ratioRunning)

    if ratioRunning < args.threshold:
        print "CRITICAL: running VMs: %d/%d (%d%%)" % (numRunning, numAll, ratioRunning)
        for server in portDownServers:
            data = "VM ID:%s  Name:%s  IP:%s\n" % (server['id'], server['name'], server['ip'])
            print data
        print traceback.format_exc()
        sys.exit(STATE_CRITICAL)
    else:
        print "OK: running VMs: %d/%d (%d%%)" % (numRunning, numAll, ratioRunning)
        sys.exit(STATE_OK)
