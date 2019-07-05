# distutils: language = c++

# comments on test layout: https://docs.pytest.org/en/latest/goodpractices.html
# run with python -m unittest tests.test_fenicsadapter

cimport precice_future
from unittest import TestCase
import numpy as np

class TestBindings(TestCase):
    """
    Test suite to check correct behaviour of python bindings.
    """

    # TODO: it would be nice to be able to mock the output of the interface directly in the test, not in test/SolverInterface.hpp
    fake_data_id = 15  # compare to test/SolverInterface.hpp, fake_data_id
    fake_dimension = 3  # compare to test/SolverInterface.hpp, fake_dimensions
    fake_mesh_id = 0  # compare to test/SolverInterface.hpp, fake_mesh_id
    fake_vertex_ids = np.array([0, 1, 2, 3, 4])  # compare to test/SolverInterface.hpp, fake_vertex_ids
    
    def test_constructor(self):
        solver_interface = precice_future.Interface("test", 0, 1)
        self.assertTrue(True)

    def test_get_dimensions(self):
        solver_interface = precice_future.Interface("test", 0, 1)
        # TODO: it would be nice to be able to mock the output of the interface directly in the test, not in test/SolverInterface.hpp
        self.assertEqual(self.fake_dimension, solver_interface.get_dimensions())  # TODO: it would be nice to be able to mock the output of the interface directly in the test, not in test/SolverInterface.hpp

    def test_get_mesh_id(self):
        solver_interface = precice_future.Interface("test", 0, 1)
        self.assertEqual(self.fake_mesh_id, solver_interface.get_mesh_id("testMesh"))

    def test_set_get_mesh_vertex(self):
        solver_interface = precice_future.Interface("test", 0, 1)
        mesh_id  = solver_interface.get_mesh_id("testMesh")
        n_vertices = 1
        position = np.random.rand(n_vertices * solver_interface.get_dimensions())
        vertex_id = solver_interface.set_mesh_vertex(mesh_id, position)
        self.assertEqual(self.fake_vertex_ids[0], vertex_id)
        self.assertEqual(n_vertices, solver_interface.get_mesh_vertex_size(mesh_id))
        self.assertTrue(np.array_equal(position, solver_interface.get_mesh_vertices(mesh_id, np.array([vertex_id]))))

    def test_set_get_mesh_vertices(self):
        solver_interface = precice_future.Interface("test", 0, 1)
        mesh_id  = solver_interface.get_mesh_id("testMesh")

        n_vertices = 3
        positions = np.random.rand(n_vertices * solver_interface.get_dimensions())
        vertex_ids = solver_interface.set_mesh_vertices(mesh_id, positions)
        self.assertTrue(np.array_equal(self.fake_vertex_ids[:n_vertices], vertex_ids))
        self.assertEqual(n_vertices, solver_interface.get_mesh_vertex_size(mesh_id))
        self.assertTrue(np.array_equal(positions, solver_interface.get_mesh_vertices(mesh_id, vertex_ids)))

    def test_read_write_block_scalar_data(self):
        solver_interface = precice_future.Interface("test", 0, 1)
        write_data = np.array([3, 7, 8], dtype=np.double)
        mesh_id  = solver_interface.get_mesh_id("testMesh")
        data_id = solver_interface.get_data_id("dummyData", mesh_id)
        self.assertEqual(data_id, self.fake_data_id)
        solver_interface.write_block_scalar_data(data_id, np.array([1, 2, 3]), write_data)
        read_data = solver_interface.read_block_scalar_data(data_id, np.array([1, 2, 3]))
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_scalar_data(self):
        solver_interface = precice_future.Interface("test", 0, 1)
        write_data = 3
        mesh_id  = solver_interface.get_mesh_id("testMesh")
        data_id = solver_interface.get_data_id("dummyData", mesh_id)
        self.assertEqual(data_id, self.fake_data_id)
        solver_interface.write_scalar_data(data_id, 1, write_data)
        read_data = solver_interface.read_scalar_data(data_id, 1)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_block_vector_data(self):
        solver_interface = precice_future.Interface("test", 0, 1)
        write_data = np.array([3, 7, 8, 7 ,6, 5], dtype=np.double)
        mesh_id  = solver_interface.get_mesh_id("testMesh")
        data_id = solver_interface.get_data_id("dummyData", mesh_id)
        self.assertEqual(data_id, self.fake_data_id)
        solver_interface.write_block_vector_data(data_id, np.array([1, 2]), write_data)
        read_data = solver_interface.read_block_vector_data(data_id, np.array([1, 2]))
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_vector_data(self):
        solver_interface = precice_future.Interface("test", 0, 1)
        write_data = np.array([1, 2, 3], dtype=np.double)
        mesh_id  = solver_interface.get_mesh_id("testMesh")
        data_id = solver_interface.get_data_id("dummyData", mesh_id)
        self.assertEqual(data_id, self.fake_data_id)
        solver_interface.write_vector_data(data_id, 1, write_data)
        read_data = solver_interface.read_vector_data(data_id, 1)
        self.assertTrue(np.array_equal(write_data, read_data))

