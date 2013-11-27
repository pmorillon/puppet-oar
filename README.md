# Puppet-oar module

This module just install OAR. See testing manifests (`tests/manifests`) for the configuration part.

## Usage


### Server

    class {
      "oar::server":
        version => "2.5",
        db      => "mysql";
    }

### Frontend (can be used on the OAR server)

    class {
      "oar::frontend":
        version => "2.5",
        db      => "mysql";
    }

### Node

    class {
      "oar::node":
        version => "2.5";
    }

### API

    class {
      "oar::api":
        version => "2.5";
    }

### Try OAR development snapshots

    class {
      "oar::server":
        version   => "2.5",
        snapshots => true;
    }


## Custom Types

### oar_queue

    oar_queue {
      "testing":
        ensure    => present,
        priority  => 1,
        scheduler => "oar_sched_gantt_with_timesharing",
        enabled   => true;
    }


### oar_property

    oar_property {
      "duration_weight":
        ensure  => present;
      ["room", "maintenance", "infiniband"]:
        ensure  => present,
        varchar => true;
    }


### oar_admission_rule

Manage OAR admission rule from puppet manifests. Only MySQL provider is available (PgSQL will be available).

    Oar_admission_rule {
      db_name     => "oar2",
      db_hostname => "localhost",
      db_user     => "oar",
      db_password => "xxxx",
      provider    => mysql
    }
    
    oar_admission_rule {
      "Dedicated interactive queue":
        content => template("igrida/oar/admission_rules/dedicated_interactive.pl");
      "Limit number of jobs":
        content => template("igrida/oar/admission_rules/limit_number_of_jobs.pl");
      "Maintenance in progress":
        ensure  => absent,
        content => '
    # Description : Rules to block submission during a maintenance
    
    if ($queue_name ne "admin") {
      die("[ADMISSION_RULES] Maintenance in progress");
    }
    ';
    }


## Librarian-puppet setup

Edit your `Puppetfile` :

    mod 'oar',
      :git => 'git://github.com/pmorillon/puppet-oar.git',
      :ref => '0.0.4'


## Testing with vagrant

### Configure

Install Ruby gems :

    $ cd tests
    $ bundle install

Download required Puppet modules :

    $ librarian-puppet install

### Booting VMS

Start 2 VMs, one server and one node :

    $ vagrant up

### Add OAR properties and resources

    vagrant@oar-server:~$ sudo oaradmin re -a /node=node1/cpu=1/core={2}/ip=192.168.1.101/ -c
    oarnodesetting -a -h node1 -p cpu=1 -p core=1 -p ip=192.168.1.101  -p cpuset=0
    oarnodesetting -a -h node1 -p cpu=1 -p core=2 -p ip=192.168.1.101  -p cpuset=1

### Submit an interactive job

    vagrant@oar-server:~$ oarsub -I
    [ADMISSION RULE] Set default walltime to 7200.
    [ADMISSION RULE] Modify resource description with type constraints
    Generate a job key...
    OAR_JOB_ID=1
    Interactive mode : waiting...
    Starting...

    Connect to OAR job 1 via the node node1
    vagrant@node1:~$

### Submit a job with OAR API

    vagrant@oar-server:~$ curl -X POST -H'Accept: application/json' -H'Content: application/json' -ki http://localhost/oarapi/jobs.json -d 'resources=core=1&command=sleep 60&name=Test'
    HTTP/1.1 201 Created
    Date: Fri, 15 Feb 2013 08:53:21 GMT
    Server: Apache/2.2.16 (Debian)
    Location: /oarapi/jobs/2
    Transfer-Encoding: chunked
    Content-Type: application/json
    
    {
       "cmd_output" : "[ADMISSION RULE] Set default walltime to 7200.\n[ADMISSION RULE] Modify resource description with type constraints\nGenerate a job key...\nOAR_JOB_ID=2\n",
       "api_timestamp" : 1360918404,
       "id" : 2,
       "links" : [
          {
             "rel" : "self",
             "href" : "/oarapi/jobs/2"
          }
       ]
    }

