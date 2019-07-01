// To compile use:
// mpic++ -I$PRECICE_ROOT/src main.cpp -lprecice -o solverdummy

#include <iostream>
#include <sstream>
#include "precice/SolverInterface.hpp"
#include <mpi.h>
#include <assert.h>

int main (int argc, char **argv)
{
  int commRank, commSize;

  MPI_Init(&argc, &argv);

  MPI_Comm_rank(MPI_COMM_WORLD, &commRank);
  MPI_Comm_size(MPI_COMM_WORLD, &commSize);

  using namespace precice;
  using namespace precice::constants;

  if (argc != 4){
    std::cout << "Usage: ./solverdummy configFile solverName meshName\n";
    std::cout << '\n';
    std::cout << "Parameter description\n";
    std::cout << "  configurationFile: Path and filename of preCICE configuration\n";
    std::cout << "  solverName:        SolverDummy participant name in preCICE configuration\n";
    std::cout << "  meshName:          Mesh in preCICE configuration that carries read and write data\n";
    return 1;
  }

  std::cout << "Starting SolverDummy on rank " << commRank << " of " << commSize << "\n";

  std::string configFileName(argv[1]);
  std::string solverName(argv[2]);
  std::string meshName(argv[3]);
  int N_all = 10;
  int N = N_all / commSize;

  assert(commSize == 2); // for the sake of testing 2 procs are enough.

  SolverInterface interface(solverName, commRank, commSize);
  interface.configure(configFileName);

  int meshID = interface.getMeshID(meshName);
  int dimensions = interface.getDimensions();

  assert(dimensions == 2); // for the sake of testing 2D cases are good enough.

  std::vector<std::vector<double>> vertices(N, std::vector<double>(dimensions, 0)); 
  std::vector<int> dataIndices(N,0);

  for(int i=0; i<N; i++){
    vertices[i][0] = i + commRank * N;  // set x coordinate
    vertices[i][1] = 0;  // set y coordinate = 0 for all vertices.
    dataIndices[i] = interface.setMeshVertex(meshID, vertices[i].data());
  }

  double dt = interface.initialize();

  std::cout << "dt = " << dt << " on rank " << commRank << "\n";

  std::vector<double> parallelData(N, commRank);

  int writeDataID = interface.getDataID("DataParallel", meshID);
  int readDataID = interface.getDataID("DataSerial", meshID);

  if (interface.isActionRequired(actionWriteInitialData())) {
    interface.writeBlockScalarData(writeDataID, N, dataIndices.data(), parallelData.data());
    interface.fulfilledAction(actionWriteInitialData());
  }

  interface.initializeData();

  std::vector<double> fromSerialData(N, -1);

  if (interface.isReadDataAvailable()) {
    interface.readBlockScalarData(readDataID, N, dataIndices.data(), fromSerialData.data());
  }

  while (interface.isCouplingOngoing()){

    if (interface.isActionRequired(actionWriteIterationCheckpoint())){
      std::cout << "DUMMY: Writing iteration checkpoint\n";
      interface.fulfilledAction(actionWriteIterationCheckpoint());
    }

    interface.writeBlockScalarData(writeDataID, N, dataIndices.data(), parallelData.data());

    interface.advance(dt);

    interface.readBlockScalarData(readDataID, N, dataIndices.data(), fromSerialData.data());

    std::ostringstream vts; 
  
    if (!fromSerialData.empty()) 
    { 
      // Convert all but the last element to avoid a trailing "," 
      std::copy(fromSerialData.begin(), fromSerialData.end()-1, 
          std::ostream_iterator<int>(vts, ", ")); 
  
      // Now add the last element with no delimiter 
      vts << fromSerialData.back(); 
    } 

    std::cout << "PARALLEL rank " << commRank << " receives: " << vts.str() << "\n";

    if (interface.isActionRequired(actionReadIterationCheckpoint())){
      std::cout << "DUMMY: Writing iteration checkpoint\n";
      interface.fulfilledAction(actionReadIterationCheckpoint());
    }
    else{
      std::cout << "DUMMY: Advancing in time\n";
    }
  }

  interface.finalize();
  MPI_Finalize();
  std::cout << "DUMMY: Closing C++ solver dummy...\n";

  return 0;
}
