import 'package:fpdart/fpdart.dart';
import 'package:orbit_app/core/errors/exceptions.dart';
import 'package:orbit_app/core/errors/failures.dart';
import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/features/projects/data/datasource/project_remote_data_source.dart';
import 'package:orbit_app/features/projects/domain/entities/project_entity.dart';
import 'package:orbit_app/features/projects/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl({required ProjectRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final ProjectRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<List<ProjectEntity>> getWorkstationProjects(String workstationId) async {
    try {
      final projects = await _remoteDataSource.getWorkstationProjects(workstationId);
      return Right(projects);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  @override
  ResultFuture<ProjectEntity> getProjectDetail(String workstationId, String projectId) async {
    try {
      final project = await _remoteDataSource.getProjectDetail(workstationId, projectId);
      return Right(project);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Map<String, dynamic>> getGithubUser(String workstationId) async {
    try {
      final user = await _remoteDataSource.getGithubUser(workstationId);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<dynamic>> getGithubCommits(String workstationId, String owner, String repo) async {
    try {
      final commits = await _remoteDataSource.getGithubCommits(workstationId, owner, repo);
      return Right(commits);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
