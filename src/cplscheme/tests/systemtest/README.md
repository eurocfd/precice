# Compile the test

```
g++ dummy_serial.cpp -lprecice -o serial
```

and

```
mpic++ dummy_parallel.cpp -lprecice -o parallel
```

# Run the test

```
 ./serial precice-config-hybrid.xml Serial NodesSerial
```

and

```
mpirun -np 2 ./parallel precice-config-hybrid.xml Parallel NodesParallel
```
