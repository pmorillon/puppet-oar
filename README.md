# Puppet-oar module

This module just install OAR. See vagrant manifests for the configuration part.

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
      provider    => mysql;
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

## Testing with vagrant

### Booting VMS

Start 2 VMs, one server and one node :

    $ vagrant up

### Add OAR properties and resources

    $ vagrant ssh server
    vagrant@oar-server:~$ sudo oarproperty -a cpu
    Added property: cpu
    vagrant@oar-server:~$ sudo oarproperty -a core
    Added property: cpu
    vagrant@oar-server:~$ sudo oarproperty -a ip -c
    Added property: cpu
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

