* What is the smallest and the biggest instance type (in terms of
  virtual CPUs and memory) that you can choose from when creating an
  instance?

```
It depends on the category of EC2 instances types (General Purpose, Compute, ...).

smallest : 1 vCPUs, 0.5GiB RAM (t2.nano)
biggest : 128 vCPUs, 2TiB RAM (p5.48xlarge)
```

* How long did it take for the new instance to get into the _running_
  state?

```
~10 seconds
```

* Using the commands to explore the machine listed earlier, respond to
  the following questions and explain how you came to the answer:

    * What's the difference between time here in Switzerland and the time set on
      the machine?
      
    ```
    The machine is in UTC and we are in CET (1 hour difference)
    ```

    * What's the name of the hypervisor?
    
    ```
    Nitro Hypervisor
    ```

    * How much free space does the disk have?
    
    ```
    6G
    ```


* Try to ping the instance ssh srv from your local machine. What do you see?
  Explain. Change the configuration to make it work. Ping the
  instance, record 5 round-trip times.

```
TODO
```

* Determine the IP address seen by the operating system in the EC2
  instance by running the `ifconfig` command. What type of address
  is it? Compare it to the address displayed by the ping command
  earlier. How do you explain that you can successfully communicate
  with the machine?

```
TODO
```
