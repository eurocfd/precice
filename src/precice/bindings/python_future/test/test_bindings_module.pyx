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
    
    def test_constructor(self):
        solver_interface = precice_future.Interface("test", 0, 1)
        self.assertTrue(True)

    def test_get_dimensions(self):
        solver_interface = precice_future.Interface("test", 0, 1)
        # TODO: it would be nice to be able to mock the output of the interface directly in the test, not in test/SolverInterface.hpp
        fake_dimension = 3  # compare to test/SolverInterface.hpp, fake_dimensions
        self.assertEqual(fake_dimension, solver_interface.get_dimensions())  # TODO: it would be nice to be able to mock the output of the interface directly in the test, not in test/SolverInterface.hpp

    def test_get_mesh_id(self):
        solver_interface = precice_future.Interface("test", 0, 1)
        # TODO: it would be nice to be able to mock the output of the interface directly in the test, not in test/SolverInterface.hpp
        fake_mesh_id = 0  # compare to test/SolverInterface.hpp, fake_mesh_id
        self.assertEqual(fake_mesh_id, solver_interface.get_mesh_id("testMesh"))

    def test_set_get_mesh_vertex(self):
        solver_interface = precice_future.Interface("test", 0, 1)
        mesh_id  = solver_interface.get_mesh_id("testMesh")
        n_vertices = 1
        position = np.random.rand(n_vertices * solver_interface.get_dimensions())
        fake_vertex_id = 0  # compare to test/SolverInterface.hpp, fake_vertex_ids[0]
        vertex_id = solver_interface.set_mesh_vertex(mesh_id, position)
        self.assertEqual(fake_vertex_id, vertex_id)
        self.assertEqual(n_vertices, solver_interface.get_mesh_vertex_size())
        self.assertEqual(position, solver_interface.get_mesh_vertices(mesh_id, np.array([vertex_id]))

    def test_set_get_mesh_vertices(self):
        solver_interface = precice_future.Interface("test", 0, 1)
        mesh_id  = solver_interface.get_mesh_id("testMesh")

        n_vertices = 3
        positions = np.random.rand(n_vertices * solver_interface.get_dimensions())
        fake_vertex_ids = np.array([0, 1, 2])  # compare to test/SolverInterface.hpp, fake_vertex_ids
        vertex_ids = solver_interface.set_mesh_vertices(mesh_id, positions)
        self.assertTrue(np.array_equal(fake_vertex_ids, vertex_ids))
        self.assertEqual(n_vertices, solver_interface.get_mesh_vertex_size())
        self.assertTrue(np.array_equal(positions, solver_interface.get_mesh_vertices(mesh_id, vertex_ids)))

    def test_read_write_block_scalar_data(self):
        solver_interface = precice_future.Interface("test", 0, 1)
        write_data = np.array([3, 7, 8], dtype=np.double)
        solver_interface.write_block_scalar_data(1, np.array([1, 2, 3]), write_data)
        read_data = solver_interface.read_block_scalar_data(1, np.array([1, 2, 3]))
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_scalar_data(self):
        solver_interface = precice_future.Interface("test", 0, 1)
        write_data = 3
        solver_interface.write_scalar_data(1, 1, write_data)
        read_data = solver_interface.read_scalar_data(1, 1)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_block_vector_data(self):
        solver_interface = precice_future.Interface("test", 0, 1)
        write_data = np.array([3, 7, 8, 7 ,6, 5], dtype=np.double)
        solver_interface.write_block_vector_data(1, np.array([1, 2]), write_data)
        read_data = solver_interface.read_block_vector_data(1, np.array([1, 2]))
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_vector_data(self):
        solver_interface = precice_future.Interface("test", 0, 1)
        write_data = np.array([1, 2, 3], dtype=np.double)
        solver_interface.write_vector_data(1, 1, write_data)
        read_data = solver_interface.read_vector_data(1, 1)
        self.assertTrue(np.array_equal(write_data, read_data))

