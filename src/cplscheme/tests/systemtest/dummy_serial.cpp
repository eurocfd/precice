// To compile use:
// mpic++ -I$PRECICE_ROOT/src main.cpp -lprecice -o solverdummy

#include <iostream>
#include <sstream>
#include "precice/SolverInterface.hpp"
#include <assert.h>

int main (int argc, char **argv)
{
  int commRank = 0;
  int commSize = 1;

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

  std::cout << "Starting SolverDummy ...\n";

  std::string configFileName(argv[1]);
  std::string solverName(argv[2]);
  std::string meshName(argv[3]);
  int N = 10;

  SolverInterface interface(solverName, commRank, commSize);
  interface.configure(configFileName);

  int meshID = interface.getMeshID(meshName);
  int dimensions = interface.getDimensions();

  assert(dimensions == 2); // for the sake of testing 2D cases are good enough.

  std::vector<std::vector<double>> vertices(N, std::vector<double>(dimensions, 0)); 
  std::vector<int> dataIndices(N,0);

  for(int i=0; i<N; i++){
    vertices[i][0] = i;  // set x coordinate
    vertices[i][1] = 0;  // set y coordinate = 0 for all vertices.
    dataIndices[i] = interface.setMeshVertex(meshID, vertices[i].data());
  }

  double dt = interface.initialize();

  std::vector<double> serialData(N, 10);

  int writeDataID = interface.getDataID("DataSerial", meshID);
  int readDataID = interface.getDataID("DataParallel", meshID);

  if (interface.isActionRequired(actionWriteInitialData())) {
    interface.writeBlockScalarData(writeDataID, N, dataIndices.data(), serialData.data());
    interface.fulfilledAction(actionWriteInitialData());
  }

  interface.initializeData();

  std::vector<double> fromParallelData(N, -1);

  if (interface.isReadDataAvailable()) {
    interface.readBlockScalarData(readDataID, N, dataIndices.data(), fromParallelData.data());
  }


  while (interface.isCouplingOngoing()){

    if (interface.isActionRequired(actionWriteIterationCheckpoint())){
      std::cout << "DUMMY: Writing iteration checkpoint\n";
      interface.fulfilledAction(actionWriteIterationCheckpoint());
    }

    interface.writeBlockScalarData(writeDataID, N, dataIndices.data(), serialData.data());

    interface.advance(dt);

    interface.readBlockScalarData(readDataID, N, dataIndices.data(), fromParallelData.data());

    std::ostringstream vts; 
  
    if (!fromParallelData.empty()) 
    { 
      // Convert all but the last element to avoid a trailing "," 
      std::copy(fromParallelData.begin(), fromParallelData.end()-1, 
          std::ostream_iterator<int>(vts, ", ")); 
  
      // Now add the last element with no delimiter 
      vts << fromParallelData.back(); 
    } 

    std::cout << "SERIAL receives: "<< vts.str() << "\n";

    if (interface.isActionRequired(actionReadIterationCheckpoint())){
      std::cout << "DUMMY: Writing iteration checkpoint\n";
      interface.fulfilledAction(actionReadIterationCheckpoint());
    }
    else{
      std::cout << "DUMMY: Advancing in time\n";
    }
  }

  interface.finalize();
  std::cout << "DUMMY: Closing C++ solver dummy...\n";

  return 0;
}
